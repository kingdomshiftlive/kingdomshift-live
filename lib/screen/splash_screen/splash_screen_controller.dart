import 'dart:async';
import 'dart:convert';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/common_service.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/screen/auth_screen/login_screen.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen.dart';

class SplashScreenController extends BaseController {
  StreamSubscription? _subscription;
  bool isOnline = true;
  bool _navigated = false;

  @override
  void onReady() {
    super.onReady();
    print('SplashScreen: onReady called');
    fetchSettings();
  }

  @override
  void onClose() {
    super.onClose();
    _subscription?.cancel();
  }

  Future<void> fetchSettings() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    // Loads gifts (and other global settings) on every app launch. This
    // was never actually called anywhere in the app before — the only
    // other call site was buried inside create-feed screen and the
    // auth-screen call was commented out, so gift data never loaded in
    // time for live streaming. Runs best-effort; a failure here should
    // never block navigation into the app.
    CommonService.instance.fetchGlobalSettings();
    bool isLoggedIn = SessionManager.instance.isLogin();
    User? savedUser = SessionManager.instance.getUser();
    _navigated = true;
    if (isLoggedIn && savedUser != null) {
      Get.off(() => DashboardScreen(myUser: savedUser));
    } else {
      Get.off(() => const LoginScreen());
    }
  }

  Future<Map<String, Map<String, String>>> downloadAndParseLanguages(
      List<Language> languages) async {
    const int maxConcurrentDownloads = 3; // Limit concurrent downloads
    final Set<Future<void>> activeDownloads = {}; // Track active downloads
    final languageData = <String, Map<String, String>>{};

    for (var language in languages) {
      if (language.code != null && language.csvFile != null) {
        // Start the download and add it to the active set
        final downloadTask = downloadAndProcessLanguage(language, languageData);
        activeDownloads.add(downloadTask);

        // Limit concurrency
        if (activeDownloads.length >= maxConcurrentDownloads) {
          // Wait for any download to complete
          await Future.any(activeDownloads);

          // Remove completed tasks from the set
          activeDownloads
              .removeWhere((task) => task == Future.any(activeDownloads));
        }
      }
    }

    // Wait for all remaining downloads to complete
    await Future.wait(activeDownloads);

    return languageData;
  }

  Future<void> downloadAndProcessLanguage(
      Language language, Map<String, Map<String, String>> languageData) async {
    try {
      final response =
          await http.get(Uri.parse(language.csvFile?.addBaseURL() ?? ''));
      if (response.statusCode == 200) {
        final csvContent = utf8.decode(response.bodyBytes);
        // Parse the CSV into a map
        final parsedMap = _parseCsvToMap(csvContent);
        languageData[language.code!] = parsedMap;

        Loggers.info('Downloaded and parsed: ${language.code}');
      } else {
        Loggers.error(
            'Failed to download ${language.code}: ${response.statusCode}');
      }
    } catch (e) {
      Loggers.error('Error downloading ${language.code}: $e');
    }
  }

  Map<String, String> _parseCsvToMap(String csvContent) {
    final rows = Csv().decode(csvContent);
    final map = <String, String>{};

    for (var row in rows) {
      if (row.length >= 2) {
        map[row[0].toString()] = row[1].toString();
      }
    }
    return map;
  }
}
