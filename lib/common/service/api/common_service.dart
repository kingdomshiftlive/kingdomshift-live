import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/file_path_model.dart';
import 'package:shortzz/model/general/location_place_model.dart';
import 'package:shortzz/model/general/place_detail.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class CommonService {
  CommonService._();

  static final CommonService instance = CommonService._();

  /// Was previously a no-op stub (`return true;`), which meant
  /// SessionManager.getSettings() always returned null and gift-sending
  /// was completely non-functional — the app never had any gift data to
  /// show. This now actually fetches from the admin panel's
  /// `virtual_gifts` table (the table the admin panel's Virtual Gifts
  /// tab writes to) and maps it into the Gift model the live-stream
  /// screen already expects, preserving any other settings already
  /// cached locally.
  Future<bool> fetchGlobalSettings() async {
    try {
      final response = await supabase.Supabase.instance.client
          .from('virtual_gifts')
          .select()
          .eq('is_active', true)
          .order('coins', ascending: true);

      final gifts = (response as List)
          .map((row) => Gift(
                id: row['id'] is int
                    ? row['id']
                    : int.tryParse(row['id'].toString()),
                coinPrice: (row['coins'] as num?)?.toInt(),
                image: row['image_url'] as String?,
                type: 'image',
                createdAt: row['created_at'] != null
                    ? DateTime.tryParse(row['created_at'])
                    : null,
                updatedAt: row['updated_at'] != null
                    ? DateTime.tryParse(row['updated_at'])
                    : null,
              ))
          .toList();

      final existing = SessionManager.instance.getSettings() ?? Setting();
      existing.gifts = gifts;
      SessionManager.instance.setSettings(existing);
      return true;
    } catch (e) {
      // Non-fatal — leave whatever settings were already cached (or
      // none) rather than crashing app startup over a gifts fetch.
      return false;
    }
  }

  Future<FilePathModel> uploadFileGivePath(XFile files,
      {Function(double percentage)? onProgress}) async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('UPLOAD FAILED: No Firebase user');
        return FilePathModel(status: false, message: 'Not logged in');
      }

      final file = File(files.path);

      if (!await file.exists()) {
        print('UPLOAD FAILED: File does not exist at ${files.path}');
        return FilePathModel(status: false, message: 'File not found');
      }

      final ext = files.path.split('.').last.toLowerCase();
      final isVideo = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'].contains(ext);
      final bucket = isVideo ? 'videos' : 'thumbnails';
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${firebaseUser.uid}.$ext';

      print('UPLOADING to bucket: $bucket, file: $fileName');
      print('File size: ${await file.length()} bytes');

      final response = await supabase.Supabase.instance.client.storage
          .from(bucket)
          .upload(fileName, file,
              fileOptions: const supabase.FileOptions(upsert: true));

      print('UPLOAD RESPONSE: $response');

      final publicUrl = supabase.Supabase.instance.client.storage
          .from(bucket)
          .getPublicUrl(fileName);

      print('UPLOAD SUCCESS: $publicUrl');
      return FilePathModel(status: true, data: publicUrl);
    } catch (e, st) {
      print('UPLOAD ERROR: $e');
      print('UPLOAD STACKTRACE: $st');
      return FilePathModel(status: false, message: e.toString());
    }
  }

  Future<StatusModel> deleteFile(String filePath) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.setting.deleteFile,
        param: {Params.filePath: filePath},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<List<Places>> searchPlace({String title = ''}) async {
    Setting? settings = SessionManager.instance.getSettings();
    Map<String, String> header = {
      Params.authorization:
          'Bearer ${settings?.placeApiAccessToken ?? 'PLACE API ACCESS TOKEN EMPTY'}'
    };
    Map<String, dynamic> body = {
      Params.textQuery: title,
      Params.maxResultCount: '${AppRes.paginationLimit}'
    };
    Uri uri = Uri.parse(WebService.google.searchTextByPlace);
    Response response = await post(uri, headers: header, body: body);
    LocationPlaceModel model =
        LocationPlaceModel.fromJson(jsonDecode(response.body));
    return model.places ?? [];
  }

  Future<List<Places>> searchNearBy(
      {required double lat, required double lon}) async {
    Setting? settings = SessionManager.instance.getSettings();
    Map<String, String> header = {
      Params.authorization:
          'Bearer ${settings?.placeApiAccessToken ?? 'PLACE API ACCESS TOKEN EMPTY'}'
    };
    Map<String, dynamic> locationRestriction = {
      Params.circle: {
        Params.center: {Params.latitude: '$lat', Params.longitude: '$lon'},
        Params.radius: '${AppRes.nearBySearchRadius}'
      }
    };
    Map<String, dynamic> body = {
      Params.includedTypes: AppRes.nearbySearchTypes,
      Params.maxResultCount: AppRes.paginationLimit.toString(),
      Params.locationRestriction: locationRestriction
    };
    Uri uri = Uri.parse(WebService.google.searchNearByPlace(lat, lon));
    Response response =
        await post(uri, headers: header, body: jsonEncode(body));
    LocationPlaceModel model =
        LocationPlaceModel.fromJson(jsonDecode(response.body));
    return model.places ?? [];
  }

  Future<PlaceDetail> getIPPlaceDetail() async {
    Map<String, dynamic> detail =
        await ApiService.instance.callGet(url: WebService.common.ipApi);
    return PlaceDetail.fromJson(detail);
  }
}
