import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/logger.dart';
import 'package:shortzz/model/general/settings_model.dart';

class AdsManager {
  AdsManager._();

  static final instance = AdsManager._();

  // Google's official test ad unit IDs for development
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  // Production fallback IDs
  static const _prodBannerAndroid = 'ca-app-pub-4518801081128136/1848744924';
  static const _prodBannerIos = 'ca-app-pub-4518801081128136/4283336571';
  static const _prodInterstitialAndroid =
      'ca-app-pub-4518801081128136/1194138806';
  static const _prodInterstitialIos = 'ca-app-pub-4518801081128136/8881057133';

  String? _getBannerAdUnitId(Setting? setting) {
    if (!kReleaseMode) {
      logger(
          'Getting Banner Ad Unit ID (Debug): ${Platform.isAndroid ? _testBannerAndroid : _testBannerIos}');
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIos;
    }
    final id =
        Platform.isAndroid ? setting?.admobBanner : setting?.admobBannerIos;
    logger('Getting Banner Ad Unit ID (Release) from Setting: $id');

    if (id != null && id.isNotEmpty) {
      return id;
    }

    // Fallback to production IDs if API fails or settings are empty
    logger(
        'Banner API ID is empty, falling back to production ID: ${Platform.isAndroid ? _prodBannerAndroid : _prodBannerIos}');
    return Platform.isAndroid ? _prodBannerAndroid : _prodBannerIos;
  }

  String? _getInterstitialAdUnitId(Setting? setting) {
    if (!kReleaseMode) {
      logger(
          'Getting Interstitial Ad Unit ID (Debug): ${Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIos}');
      return Platform.isAndroid
          ? _testInterstitialAndroid
          : _testInterstitialIos;
    }
    final id = Platform.isAndroid ? setting?.admobInt : setting?.admobIntIos;
    logger('Getting Interstitial Ad Unit ID (Release) from Setting: $id');

    if (id != null && id.isNotEmpty) {
      return id;
    }

    // Fallback to production IDs if API fails or settings are empty
    logger(
        'Interstitial API ID is empty, falling back to production ID: ${Platform.isAndroid ? _prodInterstitialAndroid : _prodInterstitialIos}');
    return Platform.isAndroid ? _prodInterstitialAndroid : _prodInterstitialIos;
  }

  void loadBannerAd({required Function(Ad) onAdLoaded}) async {
    logger('loadBannerAd called');
    Setting? setting = SessionManager.instance.getSettings();
    // Default to enable if settings are null (API failed) or if explicit status is 1
    if (setting != null) {
      if (Platform.isAndroid && setting.admobAndroidStatus == 0) {
        logger('Banner Ad is disabled for Android in settings');
        return;
      }
      if (Platform.isIOS && setting.admobIosStatus == 0) {
        logger('Banner Ad is disabled for iOS in settings');
        return;
      }
    } else {
      logger('Settings are null, proceeding with fallback IDs');
    }

    final adUnitId = _getBannerAdUnitId(setting);
    if (adUnitId == null) {
      logger('Banner Ad Unit ID is null');
      return;
    }
    logger('Loading Banner Ad with Unit ID: $adUnitId');
    BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          logger('Banner Ad successfully loaded: ${ad.adUnitId}');
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, err) {
          logger(
              'Banner Ad failed to load: $err. Error code: ${err.code}, Message: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  Future<void> loadInterstitialAd(
      {required Function(InterstitialAd) onAdLoaded}) async {
    logger('loadInterstitialAd called');
    Setting? setting = SessionManager.instance.getSettings();
    // Default to enable if settings are null (API failed) or if explicit status is 1
    if (setting != null) {
      if (Platform.isAndroid && setting.admobAndroidStatus == 0) {
        logger('Interstitial Ad is disabled for Android in settings');
        return;
      }
      if (Platform.isIOS && setting.admobIosStatus == 0) {
        logger('Interstitial Ad is disabled for iOS in settings');
        return;
      }
    } else {
      logger('Settings are null, proceeding with fallback IDs');
    }

    final adUnitId = _getInterstitialAdUnitId(setting);
    if (adUnitId == null) {
      logger('Interstitial Ad Unit ID is null');
      return;
    }
    logger('Loading Interstitial Ad with Unit ID: $adUnitId');
    await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            logger('Interstitial Ad successfully loaded: ${ad.adUnitId}');
            onAdLoaded(ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            logger(
                'InterstitialAd failed to load: $error. Error code: ${error.code}, Message: ${error.message}');
          },
        ));
  }

  void requestConsentInfoUpdate() {
    final params = ConsentRequestParameters(
        consentDebugSettings: ConsentDebugSettings(
            debugGeography: DebugGeography.debugGeographyEea,
            testIdentifiers: ['D5E5A833CA124D2CD5E33A574AF9EA88']));
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          loadForm();
        }
      },
      (FormError error) {
        // Handle the error
      },
    );
  }

  void loadForm() {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        var status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show((formError) {
            loadForm();
          });
        }
      },
      (FormError formError) {
        // Handle the error
      },
    );
  }
}
