import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';

import '../../common/service/logger.dart';

enum CompressionQuality {
  low,
  medium,
  high,
  ultra;
}

class VideoCompressor {
  /// Compress video using video_compress package, returns compressed file or null if fails
  /// This is the final compression step before server upload
  /// [progressCallback] - Optional callback function that receives progress updates (0.0 to 100.0)
  static Future<File?> compressVideo(
    String inputPath, {
    CompressionQuality quality = CompressionQuality.medium,
    Function(double progress)? progressCallback,
  }) async {
    logger('🎬 VideoCompressor: Starting video compression process');
    logger('📁 Input path: $inputPath');
    logger('⚙️ Quality setting: ${quality.name}');

    try {
      // Step 1: Validate input file exists
      logger('🔍 Step 1: Validating input file...');
      final inputFile = File(inputPath);
      // if (kDebugMode) {
      //   return inputFile;
      // }
      if (!await inputFile.exists()) {
        logger('❌ VideoCompressor: Input file does not exist: $inputPath');
        return null;
      }
      logger('✅ Input file validation passed');

      // Step 2: Check file size - if it's already small, return original
      logger('📏 Step 2: Checking file size...');
      final fileSize = await inputFile.length();
      final fileSizeMB = fileSize / (1024 * 1024);
      logger('📊 File size: ${fileSizeMB.toStringAsFixed(2)} MB (${fileSize} bytes)');

      if (fileSizeMB < 2.0) {
        logger('📹 VideoCompressor: File is already small ($fileSizeMB MB), skipping compression');
        logger('✅ Returning original file without compression');
        return inputFile;
      }

      // Step 3: Start compression
      logger('🚀 Step 3: Starting video compression...');
      logger('⏱️ Compression started at: ${DateTime.now().toIso8601String()}');

      final result = await _compressVideo(inputPath, quality, progressCallback);

      if (result != null) {
        logger('✅ VideoCompressor: Compression completed successfully');
        logger('📁 Output file: ${result.path}');

        // Final summary
        final originalFile = File(inputPath);
        final originalSize = await originalFile.length();
        final compressedSize = await result.length();
        final compressionRatio = ((originalSize - compressedSize) / originalSize * 100);
        final originalSizeMB = originalSize / (1024 * 1024);
        final compressedSizeMB = compressedSize / (1024 * 1024);

        logger('🎯 FINAL COMPRESSION SUMMARY:');
        logger('   📥 Original: ${originalSizeMB.toStringAsFixed(2)} MB');
        logger('   📤 Compressed: ${compressedSizeMB.toStringAsFixed(2)} MB');
        logger('   📉 Reduction: ${compressionRatio.toStringAsFixed(1)}%');
        logger('   💾 Space saved: ${(originalSizeMB - compressedSizeMB).toStringAsFixed(2)} MB');
        logger('   ⏱️ Total processing time: ${DateTime.now().toIso8601String()}');
      } else {
        logger('❌ VideoCompressor: Compression failed - no output file generated');
      }

      return result;
    } catch (e) {
      logger('❌ VideoCompressor: Error during compression: $e');
      logger('📊 Error type: ${e.runtimeType}');
      logger('📍 Error occurred at: ${DateTime.now().toIso8601String()}');
      return null;
    }
  }

  // /// Quick compression for smaller files with minimal quality loss
  // /// [progressCallback] - Optional callback function that receives progress updates (0.0 to 100.0)
  // static Future<File?> quickCompress(String inputPath, {Function(double progress)? progressCallback}) async {
  //   logger('⚡ VideoCompressor: Starting quick compression mode');
  //   logger('🎯 Quality preset: LOW');
  //   return compressVideo(inputPath, quality: CompressionQuality.low, progressCallback: progressCallback);
  // }

  // /// High quality compression for important videos
  // /// [progressCallback] - Optional callback function that receives progress updates (0.0 to 100.0)
  // static Future<File?> highQualityCompress(String inputPath, {Function(double progress)? progressCallback}) async {
  //   logger('💎 VideoCompressor: Starting high quality compression mode');
  //   logger('🎯 Quality preset: HIGH');
  //   return compressVideo(inputPath, quality: CompressionQuality.high, progressCallback: progressCallback);
  // }
}

// --- Video compression function ---
Future<File?> _compressVideo(
    String inputPath, CompressionQuality quality, Function(double progress)? progressCallback) async {
  logger('🏭 VideoCompressor: Starting video compression process');

  try {
    logger('📋 Compression params:');
    logger('   - Input: $inputPath');
    logger('   - Quality: ${quality.name}');

    // Step 1: Get video information
    logger('🔍 Step 1: Getting video information...');
    final mediaInfo = await VideoCompress.getMediaInfo(inputPath);
    logger('📊 VideoCompressor: Original video specs:');
    logger('   - Resolution: ${mediaInfo.width}x${mediaInfo.height}');
    logger('   - Duration: ${mediaInfo.duration}ms');
    logger('   - File size: ${(mediaInfo.filesize! / (1024 * 1024)).toStringAsFixed(2)} MB');

    // Step 2: Start compression with progress tracking
    logger('🚀 Step 2: Starting compression with progress tracking...');
    logger('⏱️ Compression started at: ${DateTime.now().toIso8601String()}');

    // Set up progress subscription
    final progressSubscription = VideoCompress.compressProgress$.subscribe((progress) {
      logger('📊 PROGRESS: ${(progress / 100).toStringAsFixed(1)}%');

      // Call the progress callback if provided
      if (progressCallback != null) {
        progressCallback(progress / 100);
      }
    });

    // Compress the video
    final result = await VideoCompress.compressVideo(
      inputPath,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false, // Keep original file
    );

    // Cancel progress subscription
    progressSubscription.unsubscribe();

    logger('⏱️ Compression completed at: ${DateTime.now().toIso8601String()}');

    // Step 3: Check results
    logger('🔍 Step 3: Checking compression results...');

    if (result != null) {
      logger('✅ Video compression successful');
      logger('📁 Output file: ${result.path}');

      // Get compressed file info
      final compressedFile = File(result.path!);
      if (await compressedFile.exists()) {
        final compressedSize = await compressedFile.length();
        final compressedSizeMB = compressedSize / (1024 * 1024);

        // Get original file info for comparison
        final originalFile = File(inputPath);
        final originalSize = await originalFile.length();
        final originalSizeMB = originalSize / (1024 * 1024);
        final compressionRatio = ((originalSize - compressedSize) / originalSize * 100);
        final spaceSavedMB = originalSizeMB - compressedSizeMB;

        // Get compressed video info
        final compressedMediaInfo = await VideoCompress.getMediaInfo(result.path!);

        logger('🎉 COMPRESSION SUCCESSFUL! 🎉');
        logger('═══════════════════════════════════════════════════════════');
        logger('📊 COMPRESSION COMPARISON REPORT');
        logger('═══════════════════════════════════════════════════════════');

        // File size comparison
        logger('📁 FILE SIZE COMPARISON:');
        logger('   📥 Original file:');
        logger('      - Size: ${originalSizeMB.toStringAsFixed(2)} MB (${originalSize} bytes)');
        logger('      - Path: $inputPath');
        logger('   📤 Compressed file:');
        logger('      - Size: ${compressedSizeMB.toStringAsFixed(2)} MB (${compressedSize} bytes)');
        logger('      - Path: ${result.path}');
        logger('');

        // Compression statistics
        logger('📈 COMPRESSION STATISTICS:');
        logger('   💾 Size reduction: ${compressionRatio.toStringAsFixed(1)}%');
        logger('   💰 Space saved: ${spaceSavedMB.toStringAsFixed(2)} MB');
        logger('   🔢 Compression factor: ${(originalSize / compressedSize).toStringAsFixed(2)}x');
        logger(
            '   📊 Efficiency: ${compressionRatio > 50 ? "Excellent" : compressionRatio > 30 ? "Good" : compressionRatio > 15 ? "Moderate" : "Low"}');
        logger('');

        // Video quality comparison
        logger('🎬 VIDEO QUALITY COMPARISON:');
        logger('   📥 Original video:');
        logger('      - Resolution: ${mediaInfo.width}x${mediaInfo.height}');
        logger('      - Duration: ${(mediaInfo.duration! / 1000).toStringAsFixed(2)}s');
        logger('   📤 Compressed video:');
        logger('      - Resolution: ${compressedMediaInfo.width}x${compressedMediaInfo.height}');
        logger('      - Duration: ${(compressedMediaInfo.duration! / 1000).toStringAsFixed(2)}s');
        logger('');

        // Quality preservation analysis
        final resolutionPreserved =
            mediaInfo.width == compressedMediaInfo.width && mediaInfo.height == compressedMediaInfo.height;
        final durationPreserved =
            (mediaInfo.duration! - compressedMediaInfo.duration!).abs() < 1000; // 1 second tolerance

        logger('✅ QUALITY PRESERVATION:');
        logger('   ${resolutionPreserved ? "✅" : "⚠️"} Resolution: ${resolutionPreserved ? "Preserved" : "Changed"}');
        logger('   ${durationPreserved ? "✅" : "⚠️"} Duration: ${durationPreserved ? "Preserved" : "Changed"}');
        logger('');

        // Performance summary
        logger('🏆 COMPRESSION SUMMARY:');
        logger('   🎯 Quality setting used: ${quality.name}');
        logger('   📉 File size reduced by: ${compressionRatio.toStringAsFixed(1)}%');
        logger('   💾 Space saved: ${spaceSavedMB.toStringAsFixed(2)} MB');
        logger('   ⏱️ Processing completed at: ${DateTime.now().toIso8601String()}');
        logger('═══════════════════════════════════════════════════════════');

        return compressedFile;
      } else {
        logger('❌ VideoCompressor: Output file not created despite successful result');
        return null;
      }
    } else {
      logger('❌ VideoCompressor: Compression failed - no result returned');
      return null;
    }
  } catch (e) {
    logger('❌ VideoCompressor: Exception during compression: $e');
    logger('📊 Exception type: ${e.runtimeType}');
    logger('📍 Exception occurred at: ${DateTime.now().toIso8601String()}');
    return null;
  }
}
