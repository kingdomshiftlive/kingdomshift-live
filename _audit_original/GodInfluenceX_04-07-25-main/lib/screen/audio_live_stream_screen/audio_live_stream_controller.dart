import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shortzz/common/controller/ads_controller.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/controller/firebase_firestore_controller.dart';
import 'package:shortzz/common/extensions/user_extension.dart';
import 'package:shortzz/common/manager/haptic_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/model/livestream/livestream_comment.dart';
import 'package:shortzz/model/livestream/livestream_user_state.dart';
import 'package:shortzz/screen/gift_sheet/send_gift_sheet.dart';
import 'package:shortzz/screen/gift_sheet/send_gift_sheet_controller.dart';
import 'package:shortzz/utilities/const_res.dart';
import 'package:shortzz/utilities/firebase_const.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../../common/service/utils/params.dart';

class AudioLiveStreamController extends BaseController {
  FirebaseFirestore db = FirebaseFirestore.instance;
  ZegoExpressEngine zegoEngine = ZegoExpressEngine.instance;

  final FirebaseFirestoreController firestoreController = Get.find<FirebaseFirestoreController>();
  final AdsController adsController = Get.find<AdsController>();

  Timer? timer;
  Timer? minViewerTimeoutTimer;
  Function? onLikeTap;

  Setting? get setting => SessionManager.instance.getSettings();

  int get minViewersThreshold => setting?.liveMinViewers ?? 0;

  int get timeoutMinutes => setting?.liveTimeout ?? 0;

  int get myUserId => SessionManager.instance.getUserID();

  List<Gift> get gifts => setting?.gifts ?? [];
  Rx<AppUser?> selectedGiftUser = Rx(null);

  RxBool isTextEmpty = true.obs;
  RxBool isMinViewerTimeout = false.obs;
  bool isHost;

  final elapsedSeconds = 0.obs;
  Timer? _timer;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds.value++;
    });
  }

  StreamSubscription<DocumentSnapshot<Livestream>>? liveStreamDocListener;
  StreamSubscription<QuerySnapshot<LivestreamUserState?>>? liveStreamUserStatesListener;
  StreamSubscription<QuerySnapshot<LivestreamComment?>>? liveStreamCommentsListener;

  TextEditingController textCommentController = TextEditingController();

  DocumentReference get liveStreamDocRef => db.collection(FirebaseConst.liveStreams).doc(liveData.value.roomID);

  CollectionReference get liveStreamUsersRef => db.collection(FirebaseConst.appUsers);

  CollectionReference get liveStreamUserStatesRef =>
      db.collection(FirebaseConst.liveStreams).doc(liveData.value.roomID).collection(FirebaseConst.userState);

  CollectionReference get liveStreamCommentsRef =>
      db.collection(FirebaseConst.liveStreams).doc(liveData.value.roomID).collection(FirebaseConst.comments);

  RxList<LivestreamUserState> audienceList = <LivestreamUserState>[].obs;
  RxList<LivestreamComment> comments = <LivestreamComment>[].obs;
  RxList<LivestreamUserState> liveUsersStates = <LivestreamUserState>[].obs;

  Rx<Livestream> liveData;
  AudioPlayer audioPlayer = AudioPlayer();

  // Media player properties for gift animations
  ZegoMediaPlayer? _mediaPlayer;
  Widget? _mediaPlayerWidget;
  int? _mediaPlayerViewID;
  RxBool isPlayingAnimation = false.obs;

  AudioLiveStreamController(this.liveData, this.isHost);

  @override
  void onInit() {
    super.onInit();
    zegoEngine.setAudioDeviceMode(ZegoAudioDeviceMode.General);
    loginRoom();
    startTimer();
    startListenEvent();
    listenLiveStreamData();
    listenUserState();
    fetchLiveStreamComments();
    WakelockPlus.enable();
  }

  @override
  void onClose() {
    super.onClose();
    WakelockPlus.disable();
    timer?.cancel();
    minViewerTimeoutTimer?.cancel();
    liveStreamUserStatesListener?.cancel();
    liveStreamCommentsListener?.cancel();
    liveStreamDocListener?.cancel();
    audioPlayer.dispose();
    stopListenEvent();
    _timer?.cancel();
    destroyMediaPlayer();
    logoutRoom();
    if (!isHost) {
      updateLiveStreamData(watchingCount: -1);
    }
    // ZegoExpressEngine.destroyEngine();
  }

  Future<ZegoRoomLoginResult> loginRoom() async {
    final roomID = liveData.value.roomID ?? '';
    final user = ZegoUser(myUserId.toString(), SessionManager.instance.getUser()?.username ?? '');

    final roomConfig = ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true;

    try {
      final result = await zegoEngine.loginRoom(roomID, user, config: roomConfig);
      if (result.errorCode != 0) {
        showSnackBar('loginRoom failed: ${result.errorCode}');
        return result;
      }

      if (isHost) {
        startHostPublish();
      }

      final userRef = liveStreamUsersRef.doc(myUserId.toString());
      final stateRef = liveStreamUserStatesRef.doc(myUserId.toString());

      if (!(await userRef.get()).exists) {
        final userModel = SessionManager.instance.getUser()?.appUser;
        if (userModel != null) await userRef.set(userModel.toJson());
      }

      final stateSnap = await stateRef
          .withConverter(
            fromFirestore: (snapshot, _) => LivestreamUserState.fromJson(snapshot.data()!),
            toFirestore: (value, _) => value.toJson(),
          )
          .get();

      if (!stateSnap.exists) {
        final user = SessionManager.instance.getUser();
        if (user != null) {
          final initialState = LivestreamUserState(
            type: isHost ? LivestreamUserType.host : LivestreamUserType.audience,
            userId: myUserId,
            audioStatus: VideoAudioStatus.on,
            videoStatus: VideoAudioStatus.offByMe,
            // Audio-only, video off
            liveCoin: 0,
            currentBattleCoin: 0,
            totalBattleCoin: 0,
            followersGained: [],
            joinStreamTime: DateTime.now().millisecondsSinceEpoch,
          );
          await stateRef.set(initialState.toJson());
          _sendCommentToFirestore(type: LivestreamCommentType.joined);

          // If host, ensure camera is disabled and video is muted in Zego
          if (isHost) {
            await zegoEngine.enableCamera(false);
            await zegoEngine.mutePublishStreamVideo(true);
            Loggers.info('Host camera disabled and video muted for audio-only stream');
          }
        }
      }

      updateLiveStreamData(watchingCount: 1);
      return result;
    } catch (e) {
      Loggers.error('Error in loginRoom: $e');
      showSnackBar('Something went wrong while joining the room.');
      rethrow;
    }
  }

  void startListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, List<ZegoUser> userList) {
      Loggers.info('onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}');
    };

    ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, List<ZegoStream> streamList, extendedData) {
      Loggers.info('onRoomStreamUpdate: roomID: $roomID, updateType: $updateType');
      if (updateType == ZegoUpdateType.Delete && streamList.any((stream) => stream.streamID == liveData.value.roomID)) {
        Get.back();
      }
    };
  }

  void stopListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
  }

  Future<void> startHostPublish() async {
    final streamID = liveData.value.roomID ?? '';

    // Explicitly disable camera for audio-only stream
    await zegoEngine.enableCamera(false);

    // Mute video publishing (audio-only stream)
    await zegoEngine.mutePublishStreamVideo(true);

    // Enable audio publishing
    await zegoEngine.mutePublishStreamAudio(false);

    // Update host's video status in Firestore
    await updateUserStateToFirestore(
      myUserId,
      videoStatus: VideoAudioStatus.offByMe,
      type: LivestreamUserType.host,
    );

    Loggers.info('Host publishing audio-only stream: camera disabled, video muted');
    startMinViewerTimeoutCheck();
    return zegoEngine.startPublishingStream(streamID);
  }

  Future<void> logoutRoom() async {
    if (isHost) {
      deleteStreamOnFirebase();
    }
    stopPublish();
    zegoEngine.logoutRoom(liveData.value.roomID ?? '');
  }

  Future<void> stopPublish() async {
    return zegoEngine.stopPublishingStream();
  }

  Future<void> updateLiveStreamData({int watchingCount = 0}) async {
    bool isExist = (await liveStreamDocRef.get()).exists;
    if (!isExist) return;

    liveStreamDocRef.update({
      if (watchingCount != 0) FirebaseConst.watchingCount: FieldValue.increment(watchingCount),
    });
  }

  void listenLiveStreamData() {
    liveStreamDocListener = liveStreamDocRef
        .withConverter<Livestream>(
          fromFirestore: (snapshot, _) => snapshot.exists ? Livestream.fromJson(snapshot.data()!) : Livestream(),
          toFirestore: (value, _) => value.toJson(),
        )
        .snapshots()
        .listen(
      (event) {
        final stream = event.data();
        if (stream != null) {
          liveData.value = stream;
        }
      },
      onError: (error) => Loggers.error('Error listening to livestream: $error'),
    );
  }

  void listenUserState() {
    liveStreamUserStatesListener = liveStreamUserStatesRef
        .withConverter(
          fromFirestore: (snapshot, options) => snapshot.exists ? LivestreamUserState.fromJson(snapshot.data()!) : null,
          toFirestore: (value, options) => value?.toJson() ?? {},
        )
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        final state = change.doc.data();
        if (state == null) continue;

        switch (change.type) {
          case DocumentChangeType.added:
            liveUsersStates.add(state);
            break;
          case DocumentChangeType.modified:
            liveUsersStates.removeWhere((u) => u.userId == state.userId);
            liveUsersStates.add(state);
            break;
          case DocumentChangeType.removed:
            liveUsersStates.removeWhere((u) => u.userId == state.userId);
            break;
        }
      }
      audienceList.value = liveUsersStates.where((element) => element.type == LivestreamUserType.audience).toList();
    });
  }

  void fetchLiveStreamComments() {
    liveStreamCommentsListener = liveStreamCommentsRef
        .withConverter(
          fromFirestore: (snapshot, options) => snapshot.exists ? LivestreamComment.fromJson(snapshot.data()!) : null,
          toFirestore: (value, options) => value?.toJson() ?? {},
        )
        .snapshots()
        .listen((querySnapshot) {
      for (var change in querySnapshot.docChanges) {
        final comment = change.doc.data();
        if (comment == null) continue;

        switch (change.type) {
          case DocumentChangeType.added:
            comments.add(comment);
            // Trigger animation for video gifts on host screen
            if (isHost && comment.commentType == LivestreamCommentType.gift && comment.giftId != null) {
              Gift? gift = gifts.firstWhereOrNull((gift) => gift.id == comment.giftId);
              if (gift?.type == 'video') {
                loadResource(videoBaseUrl + gift!.image.toString()).then((ret) async {
                  if (ret == 0) {
                    await playAnim();
                    _mediaPlayer?.getTotalDuration().then((duration) {
                      Future.delayed(Duration(milliseconds: duration + 1000), () {
                        stopAnim();
                        isPlayingAnimation.value = false;
                      });
                    });
                  }
                });
              }
            }
            Loggers.info('New comment added: ${comment.toJson()}');
            break;
          case DocumentChangeType.modified:
            final index = comments.indexWhere((c) => c.id == comment.id);
            if (index != -1) comments[index] = comment;
            break;
          case DocumentChangeType.removed:
            comments.removeWhere((c) => c.id == comment.id);
            break;
        }
      }

      // Assign gift objects to comments (for gift display/processing)
      for (var comment in comments) {
        if (comment.giftId != null) {
          comment.gift = gifts.firstWhereOrNull((gift) => gift.id == comment.giftId);
        }
      }

      comments.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    });
  }

  void onTextCommentSend() {
    String comment = textCommentController.text.trim();
    textCommentController.clear();
    isTextEmpty.value = true;
    if (comment.isEmpty) return;
    _sendCommentToFirestore(type: LivestreamCommentType.text, comment: comment);
  }

  void onGiftTap({List<AppUser> users = const []}) {
    // Get users from audience list if not provided
    List<AppUser> streamUsers =
        users.isEmpty ? liveUsersStates.map((state) => state.user).whereType<AppUser>().toList() : users;

    // Remove current user from the list
    streamUsers.removeWhere((element) => element.userId == myUserId);

    GiftManager.openGiftSheet(
      onCompletion: (giftManager) async {
        Gift gift = giftManager.gift;
        AppUser? user = giftManager.streamUser;

        int coinPrice = gift.coinPrice?.toInt() ?? 0;

        // Play animation if it's a video gift (for host)
        if (isHost && gift.type == 'video') {
          await loadResource(videoBaseUrl + gift.image.toString());
          await playAnim();
          int? duration = await _mediaPlayer?.getTotalDuration();
          if (duration != null) {
            Future.delayed(Duration(milliseconds: duration + 1000), () {
              stopAnim();
              isPlayingAnimation.value = false;
            });
          }
        }

        // Send gift comment to Firestore
        _sendCommentToFirestore(
          type: LivestreamCommentType.gift,
          giftId: gift.id,
          receiverId: user?.userId,
        );

        // Update user state with coins
        if (user?.userId != null && coinPrice > 0) {
          updateUserStateToFirestore(
            user?.userId,
            liveCoin: coinPrice,
          );
        }
      },
      giftType: GiftType.livestream,
      streamUsers: streamUsers,
    );
  }

  void _sendCommentToFirestore({
    required LivestreamCommentType type,
    String? comment,
    int? giftId,
    int? receiverId,
  }) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    try {
      await liveStreamCommentsRef.doc('$time').set(LivestreamComment(
            comment: comment,
            commentType: type,
            id: time,
            senderId: myUserId,
            giftId: giftId,
            receiverId: receiverId,
          ).toJson());
    } catch (e) {
      Loggers.error('Comment Error: $e');
    }
  }

  void startMinViewerTimeoutCheck() {
    if (minViewerTimeoutTimer?.isActive ?? false) return;
    minViewerTimeoutTimer = Timer.periodic(Duration(minutes: timeoutMinutes), (_) {
      minViewerTimeoutTimer?.cancel();
      if ((liveData.value.watchingCount ?? 0) <= minViewersThreshold) {
        isMinViewerTimeout.value = true;
        Loggers.info('Close Stream Due to Insufficient Viewers');
      }
    });
  }

  Future<void> deleteStreamOnFirebase() async {
    try {
      WriteBatch batch = db.batch();
      final usersSnapshot = await liveStreamUserStatesRef.get();
      for (var doc in usersSnapshot.docs) {
        batch.delete(doc.reference);
      }
      final commentsSnapshot = await liveStreamCommentsRef.get();
      for (var doc in commentsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(liveStreamDocRef);
      await batch.commit();
      Loggers.success('Livestream data deleted from Firestore.');
    } catch (e) {
      Loggers.error('Failed to delete livestream: $e');
    }
  }

  void toggleAudioMute() {
    LivestreamUserState? state = liveUsersStates.firstWhereOrNull((element) => element.userId == myUserId);

    if (state?.audioStatus == VideoAudioStatus.offByHost) {
      showSnackBar(LKey.theHostHasTurnedOffYourAudio.tr);
      return;
    }

    bool isAudioOn = state?.audioStatus == VideoAudioStatus.on;
    VideoAudioStatus newStatus = isAudioOn ? VideoAudioStatus.offByMe : VideoAudioStatus.on;

    // Update Firestore
    updateUserStateToFirestore(myUserId, audioStatus: newStatus);

    // Toggle microphone
    zegoEngine.muteMicrophone(isAudioOn);
    Loggers.info('Audio ${isAudioOn ? 'muted' : 'unmuted'} for user $myUserId');
  }

  Future<void> updateUserStateToFirestore(
    int? userId, {
    LivestreamUserType? type,
    VideoAudioStatus? audioStatus,
    VideoAudioStatus? videoStatus,
    int? battleCoin,
    int? liveCoin,
    int? currentBattleCoin,
    List<int>? followersGained,
    int? joinStreamTime,
  }) async {
    if (userId == null) {
      Loggers.error('updateUserStateToFirestore: userId is null');
      return;
    }

    DocumentReference reference = liveStreamUserStatesRef.doc(userId.toString());
    bool isExist = (await reference.get()).exists;
    if (!isExist) {
      Loggers.error('updateUserStateToFirestore: User state not found for userId $userId');
      return;
    }

    try {
      final updateData = <String, dynamic>{
        if (type != null) FirebaseConst.type: type.value,
        if (audioStatus != null) FirebaseConst.audioStatus: audioStatus.value,
        if (videoStatus != null) FirebaseConst.videoStatus: videoStatus.value,
        if (battleCoin != null) FirebaseConst.totalBattleCoin: battleCoin == 0 ? 0 : FieldValue.increment(battleCoin),
        if (currentBattleCoin != null)
          FirebaseConst.currentBattleCoin: currentBattleCoin == 0 ? 0 : FieldValue.increment(currentBattleCoin),
        if (liveCoin != null) FirebaseConst.liveCoin: liveCoin == 0 ? 0 : FieldValue.increment(liveCoin),
        if (followersGained != null) FirebaseConst.followersGained: followersGained,
        if (joinStreamTime != null) FirebaseConst.joinStreamTime: joinStreamTime,
      };

      await reference.update(updateData);
      Loggers.success('User state updated for userId: $userId');
    } catch (e, stack) {
      Loggers.error('Failed to update user state: $e\n$stack');
    }
  }

  void endStream() {
    HapticManager.shared.light();
    Get.bottomSheet(
      ConfirmationSheet(
        title: LKey.endStreamTitle.tr,
        description: LKey.endStreamMessage.tr,
        onTap: () async {
          if (isHost) {
            // Host: Stop recording, delete stream and stop publishing
            await stopRecording();
            await deleteStreamOnFirebase();
            await stopPublish();
            zegoEngine.logoutRoom(liveData.value.roomID ?? '');
            Loggers.success('Host ended audio live stream: ${liveData.value.roomID}');
          } else {
            // Audience: Decrement watching count and leave
            await updateLiveStreamData(watchingCount: -1);
            adsController.showInterstitialAdIfAvailable();
            zegoEngine.logoutRoom(liveData.value.roomID ?? '');
            Loggers.info('Audience left audio live stream: ${liveData.value.roomID}');
          }
          Get.back(); // Close bottom sheet
          Get.back(); // Navigate back from stream screen
        },
        positiveText: LKey.stop.tr,
      ),
      isScrollControlled: true,
    );
  }

  void onCloseAudienceBtn() {
    HapticManager.shared.light();
    Get.bottomSheet(ConfirmationSheet(
      title: LKey.exitLiveStreamTitle.tr,
      description: LKey.exitLiveStreamDescription.tr,
      onTap: () {
        adsController.showInterstitialAdIfAvailable();
        logoutRoom();
      },
    ));
  }

  var header = {Params.apikey: apiKey};

  stopRecording() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String taskId = preferences.getString('task_id') ?? '';
    if (taskId.isNotEmpty) {
      await http.get(Uri.parse('${WebService.post.stopRecording}/$taskId'), headers: header);
      Loggers.info('Recording stopped for taskId: $taskId');
    }
  }

  // Media player methods for gift animations
  Widget? get mediaPlayerWidget => _mediaPlayerWidget;

  Future<Widget?> createMediaPlayer() async {
    debugPrint('play animation video 1');

    _mediaPlayer = await ZegoExpressEngine.instance.createMediaPlayer();
    debugPrint('play animation video 2 = $_mediaPlayer');
    _mediaPlayerWidget = await ZegoExpressEngine.instance.createCanvasView((viewID) {
      debugPrint('play animation video 3 = $_mediaPlayer');
      _mediaPlayerViewID = viewID;
      debugPrint('play animation video 4 = $viewID');
      _mediaPlayer?.setPlayerCanvas(ZegoCanvas(
        viewMode: ZegoViewMode.AspectFit,
        viewID,
        alphaBlend: false,
      ));
      debugPrint('play animation video 5 = $_mediaPlayer');
    });
    update();
    debugPrint('play animation video 6 = $_mediaPlayer');
    return _mediaPlayerWidget;
  }

  Future<int> loadResource(String url, {ZegoAlphaLayoutType layoutType = ZegoAlphaLayoutType.Left}) async {
    debugPrint('Mp4 Player loadResource: $url for ${isHost ? 'host' : 'audience'}');
    int ret = -1;
    if (_mediaPlayer == null) {
      await createMediaPlayer();
    }
    if (_mediaPlayer != null) {
      try {
        // Check if URL is accessible
        final response = await http.head(Uri.parse(url));
        if (response.statusCode != 200) {
          debugPrint('Mp4 Player error: URL not accessible, status: ${response.statusCode}');
          return -1;
        }

        // Stop any currently playing animation before loading new one
        _mediaPlayer!.stop();
        log("url.......   $url");
        ZegoMediaPlayerResource source = ZegoMediaPlayerResource.defaultConfig();
        source.filePath = url;
        source.loadType = ZegoMultimediaLoadType.FilePath;

        var result = await _mediaPlayer!.loadResourceWithConfig(source);
        ret = result.errorCode;
        if (ret != 0) {
          debugPrint('Mp4 Player load error: $ret, info: ${result.errorCode}');
        } else {
          _mediaPlayer!.setVolume(100);
          debugPrint('Mp4 Player load success: $url');
        }
      } catch (e) {
        debugPrint('Mp4 Player load exception: $e');
      }
    } else {
      debugPrint('Mp4 Player error: Media player still null after initialization');
    }
    return ret;
  }

  Future<void> playAnim() async {
    if (_mediaPlayer != null) {
      isPlayingAnimation.value = true;
      await _mediaPlayer!.start();
      debugPrint('Animation started playing');
    } else {
      debugPrint('Cannot play animation: Media player is null');
    }
  }

  void pauseAnim() {
    _mediaPlayer?.pause();
    debugPrint('Animation paused');
  }

  void resumeAnim() {
    _mediaPlayer?.resume();
    debugPrint('Animation resumed');
  }

  void stopAnim() {
    isPlayingAnimation.value = false;
    _mediaPlayer?.stop();
    debugPrint('Animation stopped');
  }

  void destroyMediaPlayer() {
    if (_mediaPlayer != null) {
      ZegoExpressEngine.instance.destroyMediaPlayer(_mediaPlayer!);
      _mediaPlayer = null;
    }
  }
}
