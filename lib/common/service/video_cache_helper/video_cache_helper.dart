import 'dart:async';
import 'dart:io' as io;
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class VideoCacheHelper {
  static const _keyPrefix = 'video_cache_';
  static const expirationMinutes = 30;
  static final Map<String, Future<FileInfo>> _inflight = {};

  static final GetStorage _storage = GetStorage(_keyPrefix);
  static const key = 'customCacheKey';
  static final CacheManager _cacheManager = CacheManager(
    Config(
      key,
      // ❗ How long a file is considered "fresh".
      // After 10 minute, it's marked as "stale" and can be re-downloaded.
      stalePeriod: const Duration(minutes: expirationMinutes),

      // ❗ Maximum number of cached videos allowed.
      // If more than 10 videos are cached, the oldest will be deleted automatically.
      maxNrOfCacheObjects: 20,
      // was 10
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: HttpFileService(),
    ),
  );

  /// Returns local file if valid cache exists, otherwise null
  // Always try cache first by key, even if timestamp missing
  // static Future<FileInfo?> getValidCachedVideo(String url) async {
  //   final cacheKey = '$_keyPrefix$url';
  //   // 1) direct cache lookup by key
  //   final cached = await _cacheManager.getFileFromCache(cacheKey);
  //   if (cached != null) return cached;
  //
  //   // 2) optional: if you ever stored with raw URL earlier, try that too
  //   final cachedByUrl = await _cacheManager.getFileFromCache(cacheKey);
  //   if (cachedByUrl != null) return cachedByUrl;
  //
  //   // 3) timestamp gate (best-effort)
  //   final ts = _storage.read(cacheKey);
  //   if (ts != null) {
  //     final t = DateTime.tryParse(ts);
  //     if (t != null &&
  //         DateTime.now().difference(t).inMinutes < expirationMinutes) {
  //       final c = await _cacheManager.getFileFromCache(cacheKey);
  //       if (c != null) return c;
  //     }
  //   }
  //   return null;
  // }

  static Future<FileInfo?> getValidCachedVideo(String url) async {
    final storageKey = '$_keyPrefix$url';
    final timestampStr = _storage.read<String>(storageKey);

    if (timestampStr != null) {
      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp != null &&
          DateTime.now().difference(timestamp).inMinutes < expirationMinutes) {
        final cachedFile = await _cacheManager.getFileFromCache(storageKey);
        if (cachedFile != null) {
          print('[CACHE] Valid cached video found: ${cachedFile.file.path}');
          return cachedFile;
        }
      }
    }

    print('[CACHE] No valid cache or cache expired for $url');
    return null;
  }

  /// Downloads video and stores timestamp
  // Dedupe parallel downloads for same URL/key
  // static Future<FileInfo> downloadAndCacheVideo(String url) {
  //   final cacheKey = '$_keyPrefix$url';
  //   if (_inflight.containsKey(cacheKey)) return _inflight[cacheKey]!;
  //   final fut = _cacheManager.downloadFile(url, key: cacheKey).then((fi) {
  //     _storage.write(cacheKey, DateTime.now().toIso8601String());
  //     _inflight.remove(cacheKey);
  //     return fi;
  //   }).catchError((e) {
  //     _inflight.remove(cacheKey);
  //     throw e;
  //   });
  //   _inflight[cacheKey] = fut;
  //   return fut;
  // }
  static Future<FileInfo> downloadAndCacheVideo(String url) {
    final storageKey = '$_keyPrefix$url';
    if (_inflight.containsKey(storageKey)) return _inflight[storageKey]!;

    final future =
        _cacheManager.downloadFile(url, key: storageKey).then((fileInfo) {
      print('[DOWNLOAD] Download complete: ${fileInfo.file.path}');
      _storage.write(storageKey, DateTime.now().toIso8601String());
      _inflight.remove(storageKey);
      return fileInfo;
    }).catchError((Object e) {
      _inflight.remove(storageKey);
      throw e;
    });

    print('[DOWNLOAD] Downloading $url');
    _inflight[storageKey] = future;
    return future;
  }

  /// Clears all expired videos manually
  static Future<void> clearExpiredVideos() async {
    try {
      final allKeys = _storage.getKeys().toList();
      final List<String> validPaths = [];

      for (final key in allKeys) {
        final file = await _cacheManager.getFileFromCache(key);
        if (file != null) {
          // Keep track of valid files
          validPaths.add(file.file.path);
        } else {
          // If not in cache, remove the timestamp
          await _storage.remove(key);
          print('[CLEAR] Removed expired storage key: $key');
        }
      }

      // Read actual files from the cache directory
      final cacheDir = await getTemporaryDirectory();
      final cachePath = '${cacheDir.path}/$key/';
      final dir = io.Directory(cachePath);

      if (await dir.exists()) {
        final List<FileSystemEntity> allFiles = dir.listSync();

        // Delete files not in validPaths list
        for (final file in allFiles) {
          if (!validPaths.contains(file.path)) {
            await file.delete();
            print('[CLEAR] Deleted unused file: ${file.path}');
          }
        }

        print('[CLEAR] Valid cached paths: ${validPaths.length}');
        print(
            '[CLEAR] Total files deleted: ${allFiles.length - validPaths.length}');
      } else {
        print('[CLEAR] Cache directory does not exist: $cachePath');
      }
    } catch (e) {
      print('[ERROR] clearExpiredVideos: $e');
    }
  }

  /// Clears all video cache and related timestamp storage
  static Future<void> clearAllCache() async {
    try {
      // Delete all files from the cache directory
      final cacheDir = await getTemporaryDirectory();
      final cachePath = '${cacheDir.path}/$key/';
      final dir = io.Directory(cachePath);

      if (await dir.exists()) {
        final files = dir.listSync();
        for (final file in files) {
          try {
            await file.delete();
          } catch (e) {
            print('[WARNING] Failed to delete file: ${file.path}, error: $e');
          }
        }
        print('[CACHE] Cache directory cleared: $cachePath');
      } else {
        print('[CACHE] Cache directory not found: $cachePath');
      }

      // Clear all storage keys
      final allKeys = List<String>.from(_storage.getKeys());
      for (final key in allKeys) {
        await _storage.remove(key);
      }

      print('[CACHE] All cache keys cleared');
    } catch (e) {
      print('[ERROR] clearAllCache: $e');
    }
  }
}
