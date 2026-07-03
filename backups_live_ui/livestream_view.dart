import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/haptic_manager.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/full_name_with_blue_tick.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/model/livestream/livestream_user_state.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/audience/widget/live_stream_user_info_sheet.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LivestreamView extends StatelessWidget {
  final RxList<StreamView> streamViews;
  final LivestreamScreenController controller;

  const LivestreamView(
      {super.key, required this.streamViews, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Livestream stream = controller.liveData.value;
      final mainId = (stream.mainUserId ?? stream.hostId).toString();
      final views = List<StreamView>.from(streamViews);

      final mainIndex = views.indexWhere((v) => v.streamId == mainId);
      if (mainIndex != -1 && mainIndex != 0) {
        final mainView = views.removeAt(mainIndex);
        views.insert(0, mainView);
      }
      List<AppUser> liveUsers = controller.firestoreController.users;
      List<AppUser> allUsers = stream.getAllUsers(liveUsers);
      if (controller.isHost) {
        if (views.isNotEmpty) {
          return SizedBox.expand(child: views.first.streamView);
        }
        return const SizedBox.expand();
      }

      if (allUsers.isEmpty && views.isEmpty) {
        return _buildEmptyView();
      }

      if (views.isEmpty) {
        return const LoaderWidget();
      }

      final totalUsers = views.length;

      // 1. When main user streaming alone - always display full screen
      if (totalUsers == 1) {
        return LiveStreamUserView(
          isNameAndSpeakerVisible: false,
          streamingView: views.isNotEmpty ? views.first : StreamView(controller.liveData.value.roomID ?? "", controller.liveData.value.hostViewID ?? -1, controller.hostPreview ?? const SizedBox.shrink(), false),
          controller: controller,
        );
      }

      // 2+ users: Use layout selected by host
      final layout = stream.streamLayout ?? StreamLayout.spotlight;

      switch (layout) {
        case StreamLayout.spotlight:
          return _buildSpotlightLayout(views, totalUsers);
        case StreamLayout.grid:
          return DynamicUserView(controller: controller, streamViews: views);
        case StreamLayout.stack:
          return OneAndTwoUserView(controller: controller, streamViews: views);
        case StreamLayout.focus:
          return _buildFocusLayout(views, totalUsers);
      }
    });
  }

  Widget _buildSpotlightLayout(List<StreamView> views, int totalUsers) {
    final mainHost = views.first;
    final coHosts = views.sublist(1);

    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Row(
          children: [
            // Left half: Main host with 1:2 aspect ratio (width:height)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: AspectRatio(
                  aspectRatio: 0.5, // 1:2 aspect ratio (width:height = 1:2)
                  child: LiveStreamUserView(
                    isNameAndSpeakerVisible: false,
                    streamingView: mainHost,
                    controller: controller,
                  ),
                ),
              ),
            ),
            // Right half: Co-hosts grid matching left side height
            Expanded(
              child: _buildCoHostsGrid(
                controller: controller,
                streamViews: coHosts,
                totalUsers: totalUsers,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusLayout(List<StreamView> views, int totalUsers) {
    switch (totalUsers) {
      case 2:
        return OneAndTwoUserView(controller: controller, streamViews: views);
      case 3:
        return ThreeUserView(controller: controller, streamViews: views);
      case 4:
        return FourUserView(controller: controller, streamViews: views);
      case 5:
        return FiveUserView(controller: controller, streamViews: views);
      case 6:
        return SixUserView(controller: controller, streamViews: views);
      case 7:
        return SevenUserView(controller: controller, streamViews: views);
      case 8:
        return EightUserView(controller: controller, streamViews: views);
      default:
        return DynamicUserView(controller: controller, streamViews: views);
    }
  }

  Widget _buildEmptyView() {
    return Center(
        child: Text(
      'No users in livestream',
      style: TextStyleCustom.unboundedMedium500(color: Colors.white),
    ));
  }

  Widget _buildCoHostsGrid({
    required LivestreamScreenController controller,
    required List<StreamView> streamViews,
    required int totalUsers,
  }) {
    if (streamViews.isEmpty) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Icon(Icons.person_off, color: Colors.white54, size: 48),
        ),
      );
    }

    // 2 users: Split half - right side shows 1 user (50/50 split)
    if (totalUsers == 2) {
      return Padding(
        padding: const EdgeInsets.all(1.0),
        child: LiveStreamUserView(
          isNameAndSpeakerVisible: true,
          controller: controller,
          streamingView: streamViews.first,
        ),
      );
    }

    // 3 users: Right side split vertically - 2 users stacked (upper and lower)
    if (totalUsers == 3) {
      return Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: LiveStreamUserView(
                isNameAndSpeakerVisible: true,
                controller: controller,
                streamingView: streamViews[0],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: LiveStreamUserView(
                isNameAndSpeakerVisible: true,
                controller: controller,
                streamingView: streamViews[1],
              ),
            ),
          ),
        ],
      );
    }

    // Always use 2 columns for right side grid
    const int columns = 2;

    // For 6+ users (totalUsers >= 6), make it scrollable vertically
    if (totalUsers >= 6) {
      return _buildScrollableGrid(
        controller: controller,
        streamViews: streamViews,
        columns: columns,
      );
    }

    // For 4-5 users: Fixed 2x2 grid (max 4 slots visible)
    // Show only first 4 co-hosts in the grid
    final visibleCoHosts = streamViews.take(4).toList();
    final rows = (visibleCoHosts.length / columns).ceil();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * columns;
        final endIndex = (startIndex + columns).clamp(0, visibleCoHosts.length);
        final rowUsers = visibleCoHosts.sublist(startIndex, endIndex);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < rowUsers.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: LiveStreamUserView(
                      isNameAndSpeakerVisible: true,
                      controller: controller,
                      streamingView: rowUsers[i],
                    ),
                  ),
                ),
              ),
            // Fill remaining columns with empty views if needed
            if (rowUsers.length < columns)
              for (int i = 0; i < columns - rowUsers.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(Icons.person_off, color: Colors.white54),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        );
      }),
    );
  }

  Widget _buildScrollableGrid({
    required LivestreamScreenController controller,
    required List<StreamView> streamViews,
    required int columns,
  }) {
    final rows = (streamViews.length / columns).ceil();
    final itemHeight =
        Get.width / 2 / columns; // Each item is square (1:1 aspect ratio)

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(rows, (rowIndex) {
          final startIndex = rowIndex * columns;
          final endIndex = (startIndex + columns).clamp(0, streamViews.length);
          final rowUsers = streamViews.sublist(startIndex, endIndex);

          return SizedBox(
            height: itemHeight,
            child: Row(
              children: [
                for (int i = 0; i < rowUsers.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: LiveStreamUserView(
                          isNameAndSpeakerVisible: true,
                          controller: controller,
                          streamingView: rowUsers[i],
                        ),
                      ),
                    ),
                  ),
                // Fill remaining columns with empty views if needed
                if (rowUsers.length < columns)
                  for (int i = 0; i < columns - rowUsers.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child:
                                  Icon(Icons.person_off, color: Colors.white54),
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class DynamicUserView extends StatelessWidget {
  final LivestreamScreenController controller;
  final List<StreamView> streamViews;

  const DynamicUserView({
    super.key,
    required this.controller,
    required this.streamViews,
  });

  @override
  Widget build(BuildContext context) {
    if (streamViews.isEmpty) {
      return _buildEmptyView();
    }

    final userCount = streamViews.length;

    // Calculate optimal number of columns based on user count
    int columns = _calculateOptimalColumns(userCount);

    // Calculate number of rows needed
    final rows = (userCount / columns).ceil();

    // Build rows dynamically
    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * columns;
        final endIndex = (startIndex + columns).clamp(0, userCount);
        final rowUsers = streamViews.sublist(startIndex, endIndex);

        return Expanded(
          child: Row(
            children: [
              for (int i = 0; i < rowUsers.length; i++)
                Expanded(
                  child: LiveStreamUserView(
                    // First user (host) in first row doesn't show name/speaker
                    isNameAndSpeakerVisible: rowIndex != 0 || i != 0,
                    controller: controller,
                    streamingView: rowUsers[i],
                  ),
                ),
              // Fill remaining columns with empty views if needed (only for last row)
              if (rowUsers.length < columns && rowIndex == rows - 1)
                for (int i = 0; i < columns - rowUsers.length; i++)
                  Expanded(child: _buildEmptyUserView()),
            ],
          ),
        );
      }),
    );
  }

  int _calculateOptimalColumns(int userCount) {
    // Smart column calculation for optimal visual layout
    // Handles 9-32 users with appropriate grid layouts
    if (userCount <= 9) {
      return 3; // 3 columns for 9 users (3x3 grid)
    } else if (userCount <= 12) {
      return 4; // 4 columns for 10-12 users
    } else if (userCount <= 16) {
      return 4; // 4 columns for 13-16 users (4x4 grid)
    } else if (userCount <= 20) {
      return 4; // 4 columns for 17-20 users
    } else if (userCount <= 24) {
      return 4; // 4 columns for 21-24 users (4x6 grid)
    } else if (userCount <= 28) {
      return 4; // 4 columns for 25-28 users (4x7 grid)
    } else {
      // 29-32 users: 4 columns (4x8 grid)
      return 4;
    }
  }

  Widget _buildEmptyUserView() {
    return Container(
      color: Colors.grey[800],
      child: const Center(child: Icon(Icons.person_off, color: Colors.white54)),
    );
  }

  Widget _buildEmptyView() {
    return const Center(child: Text('No users in livestream'));
  }
}

class OneAndTwoUserView extends StatelessWidget {
  final LivestreamScreenController controller;
  final List<StreamView> streamViews;

  const OneAndTwoUserView({
    super.key,
    required this.controller,
    required this.streamViews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        streamViews.length,
        (index) => Expanded(
          child: LiveStreamUserView(
            isNameAndSpeakerVisible: index != 0,
            controller: controller,
            streamingView: streamViews[index],
          ),
        ),
      ),
    );
  }
}

class ThreeUserView extends StatelessWidget {
  final LivestreamScreenController controller;
  final List<StreamView> streamViews;

  const ThreeUserView({
    super.key,
    required this.controller,
    required this.streamViews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMainUserView(streamViews.first),
        _buildSecondaryUsersRow(streamViews.sublist(1)),
      ],
    );
  }

  Widget _buildMainUserView(StreamView user) {
    return Expanded(
      child: LiveStreamUserView(
        isNameAndSpeakerVisible: false,
        controller: controller,
        streamingView: streamViews.first,
      ),
    );
  }

  Widget _buildSecondaryUsersRow(List<StreamView> streamViews) {
    return Expanded(
      child: Row(
        children: [
          for (final streamView in streamViews.take(2))
            Expanded(
              child: LiveStreamUserView(
                controller: controller,
                streamingView: streamView,
              ),
            ),
          if (streamViews.length < 2) ...[
            for (int i = 0; i < 2 - streamViews.length; i++)
              Expanded(child: _buildEmptyUserView()),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyUserView() {
    return Container(
      color: Colors.grey[800],
      child: const Center(child: Icon(Icons.person_off, color: Colors.white54)),
    );
  }
}

class FourUserView extends StatelessWidget {
  final LivestreamScreenController controller;
  final List<StreamView> streamViews;

  const FourUserView(
      {super.key, required this.controller, required this.streamViews});

  @override
  Widget build(BuildContext context) {
    if (streamViews.isEmpty) return _buildEmptyView();

    return Column(
      children: [
        _buildTopRow(streamViews.take(2)),
        _buildBottomRow(streamViews.skip(2)),
      ],
    );
  }

  Widget _buildTopRow(Iterable<StreamView> streamViews) {
    return Expanded(
      child: Row(
        children: [
          for (final user in streamViews.take(2))
            Expanded(
              child: LiveStreamUserView(
                  isNameAndSpeakerVisible:
                      streamViews.toList().indexOf(user) != 0,
                  controller: controller,
                  streamingView: user),
            ),
          if (streamViews.length < 2) Expanded(child: _buildEmptyUserView()),
        ],
      ),
    );
  }

  Widget _buildBottomRow(Iterable<StreamView> streamViews) {
    return Expanded(
      child: Row(
        children: [
          for (final user in streamViews.take(2))
            Expanded(
              child: LiveStreamUserView(
                controller: controller,
                streamingView: user,
              ),
            ),
          if (streamViews.length < 2)
            for (int i = 0; i < 2 - streamViews.length; i++)
              Expanded(child: _buildEmptyUserView()),
        ],
      ),
    );
  }

  Widget _buildEmptyUserView() {
    return Container(
      color: Colors.grey[800],
      child: const Center(child: Icon(Icons.person_off, color: Colors.white54)),
    );
  }

  Widget _buildEmptyView() {
    return const Center(child: Text('No users in livestream'));
  }
}

class FiveUserView extends StatelessWidget {
  final LivestreamScreenController controller;
  final List<StreamView> streamViews;

  const FiveUserView(
      {super.key, required this.controller, required this.streamViews});

  @override
  Widget build(BuildContext context) {
    if (streamViews.isEmpty) return _buildEmptyView();

    return Column(
      children: [
        _buildTopRow(streamViews.take(3)),
        _buildBottomRow(streamViews.skip(3)),
      ],
    );
  }

  Widget _buildTopRow(Iterable<StreamView> streamViews) {
    return Expanded(
      child: Row(
        children: [
          for (final user in streamViews.take(3))
            Expanded(
              child: LiveStreamUserView(
                  isNameAndSpeakerVisible:
                      streamViews.toList().indexOf(user) != 0,
                  controller: controller,
                  streamingView: user),
            ),
          if (streamViews.length < 3)
            for (int i = 0; i < 3 - streamViews.length; i++)
              Expanded(child: _buildEmptyUserView()),
        ],
      ),
    );
  }

  Widget _buildBottomRow(Iterable<StreamView> streamViews) {
    return Expanded(
      child: Row(
        children: [
          for (final user in streamViews.take(2))
            Expanded(
              child: LiveStreamUserView(
                controller: controller,
                streamingView: user,
              ),
            ),
          if (streamViews.length < 2)
            for (int i = 0; i < 2 - streamViews.length; i++)
              Expanded(child: _buildEmptyUserView()),
        ],
      ),
    );
  }

  Widget _buildEmptyUserView() {
    return Container(
      color: Colors.grey[800],
      child: const Center(child: Icon(Icons.person_off, color: Colors.white54)),
    );
  }

  Widget _buildEmptyView() {
    return const Center(child: Text('No users in livestream'));
  }
}

class SixUserView extends StatelessWidget {
  final LivestreamScreenController controller;
  final List<StreamView> streamViews;

  const SixUserView(
      {super.key, required this.controller, required this.streamViews});

  @override
  Widget build(BuildContext context) {
    if (streamViews.isEmpty) return _buildEmptyView();

    return Column(
      children: [
        _buildTopRow(streamViews.take(3)),
        _buildBottomRow(streamViews.skip(3)),
      ],
    );
  }

  Widget _buildTopRow(Iterable<StreamView> streamViews) {
    return Expanded(
      child: Row(
        children: [
          for (final user in streamViews.take(3))
            Expanded(
              child: LiveStreamUserView(
                  isNameAndSpeakerVisible:
                      streamViews.toList().indexOf(user) != 0,
                  controller: controller,
                  streamingView: user),
            ),
          if (streamViews.length < 3)
            for (int i = 0; i < 3 - streamViews.length; i++)
              Expanded(child: _buildEmptyUserView()),
        ],
      ),
    );
  }

  Widget _buildBottomRow(Iterable<StreamView> streamViews) {
    return Expanded(
      child: Row(
        children: [
          for (final user in streamViews.take(3))
            Expanded(
              child: LiveStreamUserView(
                controller: controller,
                streamingView: user,
              ),
            ),
          if (streamViews.length < 3)
            for (int i = 0; i < 3 - streamViews.length; i++)
              Expanded(child: _buildEmptyUserView()),
        ],
      ),
    );
  }

  Widget _buildEmptyUserView() {
    return Container(
      color: Colors.grey[800],
      child: const Center(child: Icon(Icons.person_off, color: Colors.white54)),
    );
  }

  Widget _buildEmptyView() {
    return const Center(child: Text('No users in livestream'));
  }
}

class SevenUserView extends StatelessWidget {
  final LivestreamScreenController controller;
  final List<StreamView> streamViews;

  const SevenUserView(
      {super.key, required this.controller, required this.streamViews});

  @override
  Widget build(BuildContext context) {
    if (streamViews.isEmpty) return _buildEmptyView();

    return Column(
      children: [
        _buildTopRow(streamViews.take(4)),
        _buildBottomRow(streamViews.skip(4)),
      ],
    );
  }

  Widget _buildTopRow(Iterable<StreamView> streamViews) {
    return Expanded(
      child: Row(
        children: [
          for (final user in streamViews.take(4))
            Expanded(
              child: LiveStreamUserView(
                  isNameAndSpeakerVisible:
                      streamViews.toList().indexOf(user) != 0,
                  controller: controller,
                  streamingView: user),
            ),
          if (streamViews.length < 4)
            for (int i = 0; i < 4 - streamViews.length; i++)
              Expanded(child: _buildEmptyUserView()),
        ],
      ),
    );
  }

  Widget _buildBottomRow(Iterable<StreamView> streamViews) {
    return Expanded(
      child: Row(
        children: [
          for (final user in streamViews.take(3))
            Expanded(
              child: LiveStreamUserView(
                controller: controller,
                streamingView: user,
              ),
            ),
          if (streamViews.length < 3)
            for (int i = 0; i < 3 - streamViews.length; i++)
              Expanded(child: _buildEmptyUserView()),
        ],
      ),
    );
  }

  Widget _buildEmptyUserView() {
    return Container(
      color: Colors.grey[800],
      child: const Center(child: Icon(Icons.person_off, color: Colors.white54)),
    );
  }

  Widget _buildEmptyView() {
    return const Center(child: Text('No users in livestream'));
  }
}

class EightUserView extends StatelessWidget {
  final LivestreamScreenController controller;
  final List<StreamView> streamViews;

  const EightUserView(
      {super.key, required this.controller, required this.streamViews});

  @override
  Widget build(BuildContext context) {
    if (streamViews.isEmpty) return _buildEmptyView();

    return Column(
      children: [
        _buildTopRow(streamViews.take(4)),
        _buildBottomRow(streamViews.skip(4)),
      ],
    );
  }

  Widget _buildTopRow(Iterable<StreamView> streamViews) {
    return Expanded(
      child: Row(
        children: [
          for (final user in streamViews.take(4))
            Expanded(
              child: LiveStreamUserView(
                  isNameAndSpeakerVisible:
                      streamViews.toList().indexOf(user) != 0,
                  controller: controller,
                  streamingView: user),
            ),
          if (streamViews.length < 4)
            for (int i = 0; i < 4 - streamViews.length; i++)
              Expanded(child: _buildEmptyUserView()),
        ],
      ),
    );
  }

  Widget _buildBottomRow(Iterable<StreamView> streamViews) {
    return Expanded(
      child: Row(
        children: [
          for (final user in streamViews.take(4))
            Expanded(
              child: LiveStreamUserView(
                controller: controller,
                streamingView: user,
              ),
            ),
          if (streamViews.length < 4)
            for (int i = 0; i < 4 - streamViews.length; i++)
              Expanded(child: _buildEmptyUserView()),
        ],
      ),
    );
  }

  Widget _buildEmptyUserView() {
    return Container(
      color: Colors.grey[800],
      child: const Center(child: Icon(Icons.person_off, color: Colors.white54)),
    );
  }

  Widget _buildEmptyView() {
    return const Center(child: Text('No users in livestream'));
  }
}

class LiveStreamUserView extends StatelessWidget {
  final bool isNameAndSpeakerVisible;
  final AlignmentGeometry? alignment;
  final StreamView? streamingView;
  final LivestreamScreenController controller;

  const LiveStreamUserView({
    super.key,
    this.isNameAndSpeakerVisible = true,
    this.alignment,
    required this.streamingView,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Obx(() {
        LivestreamUserState? state = controller.liveUsersStates
            .firstWhereOrNull((element) =>
                element.userId == int.parse(streamingView?.streamId ?? ''));
        AppUser? liveUser = controller.firestoreController.users
            .firstWhereOrNull((element) =>
                element.userId == int.parse(streamingView?.streamId ?? ''));

        final userId = int.tryParse(streamingView?.streamId ?? '');
        final isMainUser = (controller.liveData.value.mainUserId ??
                controller.liveData.value.hostId) ==
            userId;

        return GestureDetector(
          onTap: () {
            if (controller.isHost && !isMainUser && isNameAndSpeakerVisible) {
              HapticManager.shared.light();
              controller.assignMainUser(userId);
            }
          },
          child: Stack(
            children: [
              if (streamingView != null) Positioned.fill(child: streamingView!.streamView),
              if (state != null && state.videoStatus != VideoAudioStatus.on)
                Stack(
                  children: [
                    CustomImage(
                        size: Size(Get.width, Get.height),
                        image: liveUser?.profile?.addBaseURL(),
                        fullName: liveUser?.fullname,
                        radius: 0),
                    LayoutBuilder(
                      builder: (context, constraints) => ClipRect(
                        child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              color: Colors.black.withValues(alpha: .5),
                            )),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: LayoutBuilder(builder: (context, constraints) {
                        double width = ((constraints.maxWidth * 50) / 100);
                        return CustomImage(
                            size: Size(width, width),
                            image: liveUser?.profile?.addBaseURL(),
                            fullName: liveUser?.fullname,
                            strokeWidth: 3);
                      }),
                    ),
                  ],
                ),
              if (state != null && state.audioStatus != VideoAudioStatus.on)
                Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      AssetRes.icMicOff,
                      height: 25,
                      width: 25,
                      color: whitePure(context).withValues(alpha: .6),
                    )),
              if (isNameAndSpeakerVisible)
                _buildUserInfoOverlay(context,
                    streamView: streamingView!,
                    state: state.obs,
                    liveUser: liveUser,
                    isMuteVisible: liveUser?.userId != controller.myUserId),
              // Show a subtle highlight when host can tap to swap
              if (controller.isHost && !isMainUser && isNameAndSpeakerVisible)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: .7),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUserInfoOverlay(BuildContext context,
      {required AppUser? liveUser,
      required Rx<LivestreamUserState?> state,
      required StreamView? streamView,
      required bool isMuteVisible}) {
    return Align(
      alignment: alignment ?? AlignmentDirectional.topStart,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            if (alignment != null && isMuteVisible)
              MuteUnMuteButton(
                isMute: (streamView?.isMuted ?? false).obs,
                onTap: () => controller.toggleStreamAudio(liveUser?.userId),
              ),
            FullNameWithBlueTick(
              username: liveUser?.username,
              fontColor: whitePure(context),
              fontSize: 12,
              isVerify: liveUser?.isVerify,
              onTap: () => _showUserActionSheet(liveUser!, state),
            ),
            if (alignment == null && isMuteVisible)
              MuteUnMuteButton(
                isMute: (streamView?.isMuted ?? false).obs,
                onTap: () => controller.toggleStreamAudio(liveUser?.userId),
              ),
          ],
        ),
      ),
    );
  }

  void _showUserActionSheet(AppUser user, Rx<LivestreamUserState?> state) {
    Get.bottomSheet(
      LiveStreamUserInfoSheet(
          isAudience: !controller.isHost,
          liveUser: user,
          controller: controller),
      isScrollControlled: true,
    );
  }
}

class MuteUnMuteButton extends StatelessWidget {
  final RxBool isMute;
  final VoidCallback? onTap;

  const MuteUnMuteButton({super.key, required this.isMute, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticManager.shared.light();
        onTap?.call();
      },
      child: Obx(
        () => Image.asset(
          isMute.value ? AssetRes.icSpeakerMute : AssetRes.icSpeaker,
          width: 24,
          height: 24,
          color: whitePure(context).withValues(alpha: .5),
        ),
      ),
    );
  }
}
