import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/screen/report_sheet/report_sheet.dart';

class ReportSheetController extends BaseController {
  List<ReportReason> reports =
      SessionManager.instance.getSettings()?.reportReason ?? [];
  Rx<ReportReason?> selectedValue = Rx(null);
  int reportId;
  ReportType reportType;

  TextEditingController descriptionController = TextEditingController();

  ReportSheetController(this.reportId, this.reportType);

  @override
  void onReady() {
    super.onReady();
    selectedValue.value = reports.isNotEmpty ? reports.first : null;
  }

  void onReportSubmit() {
    if (descriptionController.text.isEmpty) {
      return showSnackBar(LKey.provideReportReason.tr);
    }
    if (reportId == -1) {
      return Loggers.error('Invalid Post Id : $reportId');
    }
    switch (reportType) {
      case ReportType.post:
        _reportPost();
        break;
      case ReportType.user:
        _reportUser();
        break;
      case ReportType.comment:
        _reportComment();
        break;
      case ReportType.story:
        _reportStory();
        break;
    }
  }

  void _reportPost() async {
    showLoader();
    StatusModel model = await PostService.instance.reportPost(
        postId: reportId,
        reason: selectedValue.value?.title ?? '',
        description: descriptionController.text.trim());
    stopLoader();

    Get.back();
    if (model.status == true) {
      showSnackBar(LKey.reportSubmitted.tr);
    } else {
      showSnackBar(model.message?.tr.capitalizeFirst);
    }
  }

  void _reportComment() async {
    showLoader();
    StatusModel model = await PostService.instance.reportComment(
        commentId: reportId,
        reason: selectedValue.value?.title ?? '',
        description: descriptionController.text.trim());
    stopLoader();
    Get.back();
    if (model.status == true) {
      showSnackBar(LKey.reportSubmitted.tr);
    } else {
      showSnackBar(model.message?.tr.capitalizeFirst);
    }
  }

  void _reportStory() async {
    showLoader();
    StatusModel model = await PostService.instance.reportStory(
        storyId: reportId,
        reason: selectedValue.value?.title ?? '',
        description: descriptionController.text.trim());
    stopLoader();
    Get.back();
    if (model.status == true) {
      showSnackBar(LKey.reportSubmitted.tr);
    } else {
      showSnackBar(model.message?.tr.capitalizeFirst);
    }
  }

  void _reportUser() async {
    showLoader();
    StatusModel model = await UserService.instance.reportPost(
        userId: reportId,
        reason: selectedValue.value?.title ?? '',
        description: descriptionController.text.trim());
    stopLoader();

    Get.back();
    if (model.status == true) {
      showSnackBar(LKey.reportSubmitted.tr);
    } else {
      showSnackBar(model.message?.tr.capitalizeFirst);
    }
  }
}
