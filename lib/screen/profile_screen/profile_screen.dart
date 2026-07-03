import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/profile_screen/profile_screen_controller.dart';
import 'package:shortzz/screen/profile_screen/widget/profile_page_view.dart';
import 'package:shortzz/screen/profile_screen/widget/profile_tab_bar_view.dart';
import 'package:shortzz/screen/profile_screen/widget/profile_user_header.dart';

class ProfileScreen extends StatelessWidget {
  final User? user;
  final bool isTopBarVisible;
  final bool isDashBoard;
  final Function(User? user)? onUserUpdate;

  const ProfileScreen({
    super.key,
    this.user,
    this.isTopBarVisible = true,
    this.isDashBoard = false,
    this.onUserUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final User? profileUser = user ?? SessionManager.instance.getUser();
    final controller = Get.put(
      ProfileScreenController(profileUser.obs, onUserUpdate),
      tag: '${profileUser?.id ?? SessionManager.instance.getUserID()}',
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF08141F),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.onRefresh,
            child: Column(
              children: [
                if (isTopBarVisible)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: Get.back,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white),
                        ),
                        const Expanded(
                          child: Text(
                            'Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      ProfileUserHeader(controller: controller),
                      ProfileTabs(controller: controller),
                      ProfilePageView(controller: controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
