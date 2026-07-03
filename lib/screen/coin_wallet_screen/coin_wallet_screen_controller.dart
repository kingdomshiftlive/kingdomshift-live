import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/gift_wallet_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';

class CoinWalletScreenController extends BaseController {
  Rx<User?> myUser = Rx<User?>(null);
  RxList<Package> offerings = <Package>[].obs;
  Setting? get settings => null;
  RxList<CoinPlan> coinPlans = <CoinPlan>[].obs;

  final List<CoinPlan> kingdomPlans = [
    CoinPlan(100, 1, 'com.godinfx.android.mustardseed100', '\$0.99'),
    CoinPlan(250, 2, 'com.godinfx.android.widowsmite250', '\$1.99'),
    CoinPlan(500, 3, 'com.godinfx.android.faithfulservant500', '\$3.99'),
    CoinPlan(1400, 4, 'com.godinfx.android.goodsteward1400', '\$9.99'),
    CoinPlan(2200, 5, 'com.godinfx.android.fishermen2200', '\$14.99'),
    CoinPlan(3500, 6, 'com.godinfx.android.breadoflife3500', '\$19.99'),
    CoinPlan(5000, 7, 'com.godinfx.android.livingwater5000', '\$29.99'),
    CoinPlan(7800, 8, 'com.godinfx.android.armorofgod', '\$44.99'),
    CoinPlan(13500, 9, 'com.godinfx.android.treeoflife13500', '\$74.99'),
    CoinPlan(20000, 10, 'com.godinfx.android.promisedland', '\$99.99'),
    CoinPlan(25000, 11, 'com.godinfx.android.lionofjudah25000', '\$124.99'),
    CoinPlan(30000, 12, 'com.godinfx.android.pearl30000', '\$149.99'),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchData();
    fetchOfferings();
  }

  void fetchData() {
    myUser.value = SessionManager.instance.getUser();
  }

  void fetchOfferings() {
    List<Package> items = SubscriptionManager.shared.offering;
    offerings.addAll(items);
    for (var plan in kingdomPlans) {
      for (var element in items) {
        if (element.storeProduct.identifier == plan.id) {
          coinPlans.add(CoinPlan(
            plan.coin,
            plan.coinPackageId,
            element.storeProduct.identifier,
            element.storeProduct.priceString,
          ));
        }
      }
    }
    if (coinPlans.isEmpty) {
      coinPlans.addAll(kingdomPlans);
    }
  }

  void onPurchase(CoinPlan offer) {
    showLoader(barrierDismissible: false);
    try {
      Package package = offerings.firstWhere(
        (element) => element.storeProduct.identifier == offer.id,
      );
      SubscriptionManager.shared
          .makePurchaseCustom(package)
          .then((value) async {
        if (value != null) {
          String isoTime = value.nonSubscriptionTransactions.last.purchaseDate;
          DateTime dt = DateTime.parse(isoTime);
          int millis = dt.millisecondsSinceEpoch;
          User? user = await GiftWalletService.instance.buyCoins(
            id: offer.coinPackageId,
            purchasedAt: millis.toString(),
          );
          stopLoader();
          if (user != null) {
            User? updatedUser = await UserService.instance
                .fetchUserDetails(userId: myUser.value?.id);
            if (updatedUser != null) {
              myUser.value = updatedUser;
              SessionManager.instance.setUser(myUser.value);
            }
          }
        } else {
          stopLoader();
        }
      });
    } catch (e) {
      stopLoader();
      showSnackBar('Purchase unavailable. Please try again later.');
    }
  }
}

class CoinPlan {
  int coin;
  int coinPackageId;
  String id;
  String priceString;
  CoinPlan(this.coin, this.coinPackageId, this.id, this.priceString);
}
