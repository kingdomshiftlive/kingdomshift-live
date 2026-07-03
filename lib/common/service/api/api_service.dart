import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/functions/debounce_action.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/screen/create_feed_screen/video_copression_helper.dart';
import 'package:shortzz/screen/session_expired_screen/session_expired_screen.dart';
import 'package:shortzz/utilities/const_res.dart';

class CancelToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }

  void dispose() {
    _isCancelled = false;
  }
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  final Map<CancelToken, http.Client> _activeClients = {};

  var header = {Params.apikey: apiKey};

  Future<T> call<T>({
    required String url,
    Map<String, dynamic>? param,
    CancelToken? cancelToken,
    bool cancelAuthToken = false,
    T Function(Map<String, dynamic> json)? fromJson,
    Function()? onError,
  }) async {
    final client = http.Client();
    if (cancelToken != null && cancelToken.isCancelled) {
      _activeClients[cancelToken] = client;
    }

    Map<String, String> params = {};
    param?.removeWhere(
        (key, value) => value == null || value == 'null' || value == '');
    param?.forEach((key, value) {
      params[key] = "$value";
    });

    if (!cancelAuthToken) {
      header[Params.authToken] = SessionManager.instance.getAuthToken();
    }
    Loggers.info("URL: $url");
    Loggers.info("header: $header");
    Loggers.info("Parameters: ${params.isEmpty ? "Empty" : params}");
    try {
      http.Response response;
      try {
        response = await client
            .post(Uri.parse(url), headers: header, body: params)
            .timeout(const Duration(seconds: 8));
      } catch (e) {
        Loggers.error("API call skipped (no backend): $url");
        if (fromJson != null) {
          return fromJson({});
        }
        return {} as T;
      }

      Loggers.success(response.statusCode);
      if (cancelToken?.isCancelled ?? false) {
        if (kDebugMode) {
          print("Request cancelled: $url");
        }
        throw Exception('Request was cancelled');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        if (decodedResponse['message'] == 'this user is freezed!') {
          DebounceAction.shared.call(() {
            Get.offAll(
                () => const SessionExpiredScreen(type: SessionType.freeze));
          });
          return decodedResponse as T;
        }

        if (decodedResponse['status'] == false) {
          Loggers.error('API RESPONSE : ${decodedResponse['message']}');
          onError?.call();
        }

        // var prettyString =
        //     const JsonEncoder.withIndent('  ').convert(decodedResponse);
        // Loggers.info(prettyString);

        // Use the provided `fromJson` function to parse the response
        if (fromJson != null) {
          return fromJson(decodedResponse);
        }

        // If no `fromJson` is provided, return the raw response
        return decodedResponse as T;
      } else if (response.statusCode == 401) {
        Loggers.error('Unauthorized Error 401: ${response.statusCode}');
        DebounceAction.shared.call(() {
          Get.offAll(
              () => const SessionExpiredScreen(type: SessionType.unauthorized));
        });
        throw Exception("Unauthorized Error: ${response.statusCode}");
      } else if (response.statusCode == 404) {
        Loggers.error('Please check baseURL in const.dart file');
        throw Exception("URL Error: ${response.statusCode} - $url");
      } else {
        final errorBody = response.body;
        final errorMessage = _extractErrorMessage(errorBody);
        Loggers.error('HTTP Error: $errorMessage');
        // Handle HTTP errors
        throw Exception(
            "HTTP Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } on HttpException {
      throw Exception('Could not connect to the server');
    } on FormatException catch (e) {
      // Handle JSON decoding errors
      Loggers.error("Invalid JSON format: ${e.message}");
      throw Exception("Invalid JSON format: ${e.message}");
    } on Exception catch (e) {
      Loggers.error("Unexpected error : $e");
      rethrow;
    } finally {
      _cleanupClient(cancelToken);
    }
  }

  String _extractErrorMessage(String responseBody) {
    final regex = RegExp(
      r'<!--\s*(.*?)\s*#0 ', // Matches everything between <!-- and #0
      dotAll: true,
    );
    final match = regex.firstMatch(responseBody);
    return match?.group(1)?.trim() ??
        "Unknown error occurred: ${_shorten(responseBody)}";
  }

  /// Shortens the response body if no specific error is found
  String _shorten(String responseBody) {
    const maxLength = 100;
    return responseBody.length > maxLength
        ? "${responseBody.substring(0, maxLength)}..."
        : responseBody;
  }

  Future<T> callGet<T>({required String url}) async {
    http.Response response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }

  Future<T> multiPartCallApi<T>({
    required String url,
    Map<String, dynamic>? param,
    required Map<String, List<XFile?>> filesMap,
    Function(double percentage)? onProgress,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    final client = http.Client();
    if (cancelToken != null) {
      _activeClients[cancelToken] = client;
    }

    final request = MultipartRequest(
      'POST',
      Uri.parse(url),
      onProgress: (bytes, totalBytes) {
        if (onProgress != null) {
          onProgress(bytes / totalBytes);
        }
      },
    );

    Map<String, String> params = {};
    param?.removeWhere((key, value) => value == null || value == 'null');
    param?.forEach((key, value) {
      params[key] = "$value";
    });

    request.fields.addAll(params);
    request.headers.addAll(header);

    // Process all files and apply video compression where needed
    for (final keyName in filesMap.keys) {
      final files = filesMap[keyName]!;
      for (final xFile in files) {
        if (xFile != null && xFile.path.isNotEmpty) {
          // Apply video compression if it's a video file
          final finalFile = await _processVideoFile(xFile);
          final file = File(finalFile.path);
          final multipartFile = http.MultipartFile(
              keyName, file.readAsBytes().asStream(), file.lengthSync(),
              filename: finalFile.name);
          request.files.add(multipartFile);
        }
      }
    }
    Loggers.info("URL : $url");
    Loggers.info("HEADERS : ${request.headers}");
    Loggers.info("FIELDS : ${request.fields}");
    Loggers.info("FILES : ${request.files.map((e) => e)}");

    try {
      http.StreamedResponse responseStream;
      try {
        responseStream =
            await client.send(request).timeout(const Duration(seconds: 8));
      } catch (e) {
        Loggers.error("multipart API skipped (no backend): $url");
        if (fromJson != null) {
          return fromJson({});
        }
        return {} as T;
      }
      if (cancelToken?.isCancelled ?? false) {
        if (kDebugMode) {
          Loggers.error("Request cancelled: $url");
        }
        throw Exception('Request was cancelled');
      }

      final responseStr = await responseStream.stream.bytesToString();
      final decodedResponse = jsonDecode(responseStr) as Map<String, dynamic>;

      if (kDebugMode) {
        // Loggers.info(responseStr);
      }
      if (decodedResponse['status'] == false) {
        Loggers.error(decodedResponse['message']);
      }
      // Use the provided `fromJson` function to parse the response
      if (fromJson != null) {
        return fromJson(decodedResponse);
      }

      // If no `fromJson` is provided, return the raw response
      return decodedResponse as T;
    } finally {
      _cleanupClient(cancelToken);
    }
  }

  void _cleanupClient(CancelToken? cancelToken) {
    if (cancelToken != null) {
      _activeClients[cancelToken]?.close();
      _activeClients.remove(cancelToken);
    }
  }

  Future<void> useAndDeleteFile(File file) async {
    try {
      // Use the file as needed
      Loggers.warning('File path: ${file.path}');

      // Delete the file after use
      if (await file.exists()) {
        await file.delete();
        Loggers.success('File deleted from: ${file.path}');
      }
    } catch (e) {
      Loggers.error('Error: $e');
    }
  }

  /// Process video files by applying compression before upload
  /// This ensures all videos are optimized without disrupting existing functionality
  Future<XFile> _processVideoFile(XFile originalFile) async {
    try {
      // Check if it's a video file
      if (!_isVideoFile(originalFile.path)) {
        return originalFile; // Return original if not a video
      }

      Loggers.info(
          '🎬 Video file detected in API upload, applying compression...');

      // Apply video compression
      final compressedFile =
          await VideoCompressor.compressVideo(originalFile.path);

      if (compressedFile != null) {
        Loggers.success('✅ Video compressed successfully for API upload');
        return XFile(compressedFile.path);
      } else {
        Loggers.warning('⚠️ Video compression failed, using original file');
        return originalFile; // Fallback to original file
      }
    } catch (e) {
      Loggers.error('❌ Error during video compression in API: $e');
      return originalFile; // Fallback to original file
    }
  }

  /// Check if the file is a video file based on extension
  bool _isVideoFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', 'webm', 'm4v']
        .contains(extension);
  }
}

class MultipartRequest extends http.MultipartRequest {
  MultipartRequest(
    super.method,
    super.url, {
    this.onProgress,
  });

  final void Function(int bytes, int totalBytes)? onProgress;

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final total = contentLength;
    int bytes = 0;

    final transformer = StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: (data, sink) {
        bytes += data.length;
        if (onProgress != null) {
          onProgress!(bytes, total);
        }
        sink.add(data);
      },
    );

    return http.ByteStream(byteStream.transform(transformer));
  }

  /// Process video files by applying compression before upload
  /// This ensures all videos are optimized without disrupting existing functionality
  Future<XFile> _processVideoFile(XFile originalFile) async {
    try {
      // Check if it's a video file
      if (!_isVideoFile(originalFile.path)) {
        return originalFile; // Return original if not a video
      }

      Loggers.info(
          '🎬 Video file detected in API upload, applying compression...');

      // Apply video compression
      final compressedFile =
          await VideoCompressor.compressVideo(originalFile.path);

      if (compressedFile != null) {
        Loggers.success('✅ Video compressed successfully for API upload');
        return XFile(compressedFile.path);
      } else {
        Loggers.warning('⚠️ Video compression failed, using original file');
        return originalFile; // Fallback to original file
      }
    } catch (e) {
      Loggers.error('❌ Error during video compression in API: $e');
      return originalFile; // Fallback to original file
    }
  }

  /// Check if the file is a video file based on extension
  bool _isVideoFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', 'webm', 'm4v']
        .contains(extension);
  }
}
