import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/live_stream/livestream_history/widget/livestream_history_item.dart';

import 'livestream_history_controller.dart';

class LivestreamHistoryScreen extends StatefulWidget {
  final String userId;

  const LivestreamHistoryScreen({super.key, required this.userId});

  @override
  State<LivestreamHistoryScreen> createState() =>
      _LivestreamHistoryScreenState();
}

class _LivestreamHistoryScreenState extends State<LivestreamHistoryScreen> {
  late LivestreamHistoryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LivestreamHistoryController(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.refreshInt.value > 0) {}
      if (controller.isLoading.value) {}
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).primaryColor,
              expandedHeight: 150.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Livestream History',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColorDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
            if (false)
              SliverToBoxAdapter(
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                            child:
                                CircularProgressIndicator(color: Colors.white)),
                      )
                    : controller.livestreams.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No livestreams found',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.6,
                            ),
                            itemCount: controller.livestreams.length,
                            itemBuilder: (context, index) {
                              final livestream = controller.livestreams[index];
                              return LivestreamItemWidget(
                                userId: widget.userId,
                                livestream: livestream,
                                videoUrl: controller
                                    .getFullVideoUrl(livestream.video),
                              );
                            },
                          ),
              ),
            if (controller.livestreams.isNotEmpty)
              SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.6,
                ),
                itemCount: controller.livestreams.length,
                itemBuilder: (context, index) {
                  final livestream = controller.livestreams[index];
                  return LivestreamItemWidget(
                    userId: widget.userId,
                    livestream: livestream,
                    videoUrl: controller.getFullVideoUrl(livestream.video),
                  );
                },
              ),
            if (controller.isLoading.value)
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            if (controller.livestreams.isEmpty &&
                controller.isLoading.value == false)
              SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No livestreams found',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 20,
              ),
            ),
          ],
        ),
      );
    });
  }
}
