import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/controller/firebase_firestore_controller.dart';
import 'package:shortzz/common/extensions/user_extension.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/model/livestream/livestream_user_state.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/audio_live_stream_screen/audio_live_stream_screen.dart';
import 'package:shortzz/utilities/firebase_const.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../../common/service/utils/params.dart';
import '../../../utilities/const_res.dart';

class CreateAudioLiveStreamController extends BaseController {
  final TextEditingController titleController = TextEditingController();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseFirestoreController firestoreController =
      Get.find<FirebaseFirestoreController>();

  Future<void> createLiveStream() async {
    // Validate user
    User? user = SessionManager.instance.getUser();
    if (user == null) {
      Loggers.error('User Not found. Cannot start audio live stream.');
      showSnackBar('User not found. Please login again.');
      return;
    }

    int userId = user.id ?? -1;
    if (userId == -1) {
      Loggers.error('Invalid User ID: $userId');
      showSnackBar('Invalid user ID. Please login again.');
      return;
    }

    // Validate Zego settings
    final settings = SessionManager.instance.getSettings();
    final appIdStr = settings?.zegoAppId ?? '0';
    final appSign = settings?.zegoAppSign ?? '';

    if (appIdStr.isEmpty || appSign.isEmpty) {
      Loggers.error('Zego App ID or Sign not configured.');
      showSnackBar(
          'Live stream configuration is missing. Please contact support.');
      return;
    }

    int appId;
    try {
      appId = int.parse(appIdStr);
      if (appId == 0) {
        throw FormatException('Invalid app ID');
      }
    } catch (e) {
      Loggers.error('Invalid Zego App ID: $appIdStr');
      showSnackBar(
          'Invalid live stream configuration. Please contact support.');
      return;
    }

    // Show loader
    showLoader();

    try {
      // Initialize Zego Engine
      await ZegoExpressEngine.createEngineWithProfile(
        ZegoEngineProfile(appId, ZegoScenario.Default, appSign: appSign),
      );
      Loggers.success('Zego Engine initialized successfully');

      // Create timestamp
      int time = DateTime.now().millisecondsSinceEpoch;

      // Create Livestream model using extension method (same as video stream)
      Livestream livestream = user.livestream(
        type: LivestreamType.audioLivestream,
        time: time,
        description: titleController.text.trim().isNotEmpty
            ? titleController.text.trim()
            : 'Audio Live Stream',
        restrictToJoin: 0,
        hostViewId: -1,
      );

      // Create LivestreamUser model
      AppUser livestreamUser = user.appUser;

      // Create LivestreamUserState model for audio-only stream
      LivestreamUserState livestreamUserState = LivestreamUserState(
        type: LivestreamUserType.host,
        userId: userId,
        audioStatus: VideoAudioStatus.on,
        videoStatus: VideoAudioStatus.offByMe, // Audio-only: video disabled
        liveCoin: 0,
        currentBattleCoin: 0,
        totalBattleCoin: 0,
        followersGained: [],
        joinStreamTime: time,
      );

      Loggers.info('Creating audio live stream...');
      Loggers.info('Livestream Model: ${livestream.toJson()}');
      Loggers.info('Livestream User Model: ${livestreamUser.toJson()}');
      Loggers.info(
          'Livestream User State Model: ${livestreamUserState.toJson()}');

      // Use FirebaseConst.liveStreams (correct collection name)
      DocumentReference livestreamRef =
          db.collection(FirebaseConst.liveStreams).doc('$userId');
      DocumentReference usersRef =
          db.collection(FirebaseConst.appUsers).doc('$userId');
      DocumentReference userStateRef =
          livestreamRef.collection(FirebaseConst.userState).doc('$userId');

      WriteBatch batch = db.batch();

      // Set all required documents
      batch.set(livestreamRef, livestream.toJson());
      batch.set(usersRef, livestreamUser.toJson());
      batch.set(userStateRef, livestreamUserState.toJson());

      // Commit batch operation
      await batch.commit();

      Loggers.success('Audio livestream started successfully!');

      // Start recording
      startRecording(livestream.roomID ?? '');

      // Navigate to audio live stream screen
      Get.off(() => AudioLiveStreamScreen(liveData: livestream, isHost: true));
    } catch (e, stackTrace) {
      Loggers.error('Failed to start audio live stream: $e');
      Loggers.error('StackTrace: $stackTrace');
      showSnackBar('Failed to start audio live stream. Please try again.');
    } finally {
      stopLoader(); // Ensure loader stops in all cases
    }
  }

  var header = {Params.apikey: apiKey};

  Future<void> startRecording(String streamId) async {
    http.Response res = await http.get(
        Uri.parse('${WebService.post.startRecording}/$streamId'),
        headers: header);
    if (res.statusCode == 200) {
      var response = jsonDecode(res.body);
      Loggers.info('Recording started: ${response.toString()}');
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String taskId = response['Data']['TaskId'];
      await preferences.setString('task_id', taskId);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }
}
