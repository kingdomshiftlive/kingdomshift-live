import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class BaseController extends FullLifeCycleController {
  RxBool isLoading = false.obs;
  RxInt refreshInt = 0.obs;
  static final share = BaseController();

  void showLoader({bool barrierDismissible = true}) async {
    if (isLoading.value) return;
    if (Get.isSnackbarOpen) {
      Get.back();
    }
    isLoading.value = true;
    refreshInt.value = DateTime.now().millisecondsSinceEpoch;
    await Get.dialog(const LoaderWidget(),
        barrierDismissible: barrierDismissible);
    isLoading.value = false;
    refreshInt.value = DateTime.now().millisecondsSinceEpoch;
  }

  void stopLoader() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  void showSnackBar(String? title, {int second = 2}) {
    if (Get.isSnackbarOpen) {
      return;
    }

    // Helper function to safely show snackbar with retry logic
    void _showSnackbarSafely({int retryCount = 0}) {
      if (retryCount > 3) {
        // Max retries reached, silently fail to prevent crashes
        return;
      }

      try {
        // Try to get context from Get.key which should have overlay
        final context = Get.key.currentContext ?? Get.context;
        final bgColor = context != null ? blackPure(context) : Colors.black87;
        final textColor = context != null ? whitePure(context) : Colors.white;

        // Use Get.snackbar which handles overlay automatically
        Get.snackbar(
          '',
          title?.capitalizeFirst?.tr ?? '',
          backgroundColor: bgColor,
          colorText: textColor,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          padding: const EdgeInsets.all(15),
          borderRadius: 10,
          isDismissible: true,
          duration: Duration(seconds: second),
          snackPosition: SnackPosition.TOP,
          messageText: context != null
              ? Text(
                  title?.capitalizeFirst?.tr ?? '',
                  style: TextStyleCustom.outFitRegular400(
                      color: textColor, fontSize: 17),
                )
              : Text(
                  title?.capitalizeFirst?.tr ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ),
          titleText: const SizedBox.shrink(),
        );
      } catch (e) {
        // If snackbar fails (overlay not available), retry after delay
        Future.delayed(Duration(milliseconds: 200 * (retryCount + 1)), () {
          _showSnackbarSafely(retryCount: retryCount + 1);
        });
      }
    }

    // Use SchedulerBinding to ensure overlay is available after dialogs close
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showSnackbarSafely();
    });
  }

  void stopSnackBar() {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
  }
}
