import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/utilities/firebase_const.dart';

class MessageScreenController extends GetxController {
  var selectedTab = 0.obs;
  RxList<ChatThread> threads = <ChatThread>[].obs;
  RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _listenToConversations();
  }

  void _listenToConversations() {
    final myId = SessionManager.instance.getUserID();
    if (myId == -1) {
      isLoading.value = false;
      return;
    }
    _sub = FirebaseFirestore.instance
        .collection(FirebaseConst.users)
        .doc(myId.toString())
        .collection(FirebaseConst.usersList)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs
          .map((doc) => ChatThread.fromJson(doc.data()))
          .where((thread) => thread.isDeleted != true)
          .toList();
      threads.value = list;
      isLoading.value = false;
    }, onError: (_) {
      isLoading.value = false;
    });
  }

  void onLongPress([dynamic item, dynamic context, dynamic index]) {
    // Safe placeholder for conversation long-press actions.
    // Later this can open archive/delete/mute/pin options.
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
