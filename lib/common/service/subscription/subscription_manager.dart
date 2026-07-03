import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/utilities/const_res.dart';

import '../logger.dart';

bool isPurchaseConfig = false;
RxBool isSubscribe = false.obs;

class SubscriptionManager with LoggerMixin {
  static var shared = SubscriptionManager();
  List<Package> packages = [];
  List<Package> offering = [];

  Future<void> initPlatformState() async {
    logs("🚀 Initializing subscription platform state...");
    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      if (revenueCatAndroidApiKey.isNotEmpty) {
        configuration = PurchasesConfiguration(revenueCatAndroidApiKey)
          ..appUserID = SessionManager.instance.getUserID().toString();
        Purchases.setLogLevel(LogLevel.debug);
        await Purchases.configure(configuration);
        logs("✅ Android RevenueCat configured successfully");
      } else {
        logs("⚠️ Android RevenueCat API key is empty");
      }
    } else if (Platform.isIOS) {
      logs("revenueCatAppleApiKey: $revenueCatAppleApiKey");
      if (revenueCatAppleApiKey.isNotEmpty) {
        configuration = PurchasesConfiguration(revenueCatAppleApiKey)
          ..appUserID = SessionManager.instance.getUserID().toString();
        Purchases.setLogLevel(LogLevel.debug);
        await Purchases.configure(configuration);
        logs("✅ iOS RevenueCat configured successfully");
      } else {
        logs("⚠️ iOS RevenueCat API key is empty");
      }
    }
    await checkIsConfigured();
    await fetchOfferings();
    logs("🎯 Subscription platform initialization completed");
  }

  bool checkSubscription(CustomerInfo customerInfo) {
    if (customerInfo.latestExpirationDate == null ||
        customerInfo.latestExpirationDate!.isEmpty) {
      isSubscribe.value = false;
      logs("📋 No subscription expiration date found");
    } else {
      DateTime dt1 =
          DateTime.parse(customerInfo.latestExpirationDate ?? '').toLocal();
      DateTime dt2 = DateTime.now();

      int leftSecond = dt1.difference(dt2).inSeconds;
      log('⏱️ Expire Time : $dt1 == Current Time : $dt2 || Time Left: ${leftSecond > 0 ? leftSecond : 0} seconds');

      if (dt1.compareTo(dt2) < 0) {
        isSubscribe.value = false;
      }
      if (dt1.compareTo(dt2) > 0) {
        isSubscribe.value = true;
      }
    }

    logs(
        '🔔 Subscription Status: ${isSubscribe.value ? 'Active' : 'InActive'}');
    return isSubscribe.value;
  }

  Future<void> subscriptionListener() async {
    try {
      logs("👂 Setting up subscription listener...");
      Purchases.addCustomerInfoUpdateListener((customerInfo) async {
        int status = checkSubscription(customerInfo) ? 1 : 0;
        User? user = SessionManager.instance.getUser();
        if (user?.isVerify == status) {
          logs("📊 User verification status unchanged: $status");
          return;
        }
        logs("🔄 Updating user verification status to: $status");
        UserService.instance.updateUserDetails(isVerify: status);
      });
      logs("✅ Subscription listener setup completed");
    } on PlatformException catch (e) {
      logs('❌ RevenueCat Error: ${e.message.toString()}');
    }
  }

  Future<void> checkIsConfigured() async {
    isPurchaseConfig = await Purchases.isConfigured;
    logs('🔧 Purchase configuration status: $isPurchaseConfig');
  }

  Future<void> login(String appUserID) async {
    logs("⏭️ RevenueCat login skipped for now. User: $appUserID");
  }

  Future<(Offering?, String?)> fetchOfferings() async {
    try {
      logs("📦 Fetching subscription offerings...");
      Offerings offerings = await Purchases.getOfferings();

      offering.addAll(offerings.current?.availablePackages
              .where((element) => element.packageType == PackageType.custom) ??
          []);

      packages.addAll(offerings.current?.availablePackages
              .where((element) => element.packageType != PackageType.custom) ??
          []);
      packages
          .sort((a, b) => b.storeProduct.price.compareTo(a.storeProduct.price));

      logs(
          "✅ Found ${packages.length} packages and ${offering.length} custom offerings");
      return (offerings.current, null);
    } on PlatformException catch (e) {
      logs('❌ Error fetching offerings: ${e.message.toString()}');
      return (null, e.message);
    }
  }

  Future<bool?> checkSubscriptionStatus() async {
    try {
      logs("🔍 Checking subscription status...");
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return checkSubscription(customerInfo);
    } on PlatformException catch (e) {
      logs('❌ Error checking subscription status: ${e.message.toString()}');
    }
    return null;
  }

  Future<bool?> makePurchase(Package package) async {
    try {
      logs("💳 Initiating purchase for package: ${package.identifier}");
      PurchaseResult purchaseResult = await Purchases.purchasePackage(package);
      CustomerInfo customerInfo = purchaseResult.customerInfo;
      bool isSubscribed = checkSubscription(customerInfo);
      logs(
          "${isSubscribed ? '✅' : '❌'} Purchase ${isSubscribed ? 'successful' : 'failed'}");
      return isSubscribed;
    } on PlatformException catch (e) {
      logs("❌ Purchase error: $e");
      return null;
    }
  }

  Future<CustomerInfo?> makePurchaseCustom(Package package) async {
    try {
      logs("💳 Initiating custom purchase for package: ${package.identifier}");
      PurchaseResult purchaseResult = await Purchases.purchasePackage(package);
      CustomerInfo info = purchaseResult.customerInfo;
      logs("✅ Custom purchase successful");
      return info;
    } on PlatformException catch (e) {
      logs("❌ Custom purchase error: ${e.message}");
      return null;
    }
  }

  Future<bool?> restorePurchase() async {
    try {
      logs("🔄 Restoring purchases...");
      CustomerInfo restoredInfo = await Purchases.restorePurchases();
      bool isSubscribed = checkSubscription(restoredInfo);
      logs(
          "${isSubscribed ? '✅' : '❌'} Purchase restoration ${isSubscribed ? 'successful' : 'failed'}");
      return isSubscribed;
    } on PlatformException catch (e) {
      logs("❌ Purchase restoration error: ${e.toString()}");
      return null;
    }
  }
}
