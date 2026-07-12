import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:shortzz/screen/cast_ai_screen/cast_ai_controller.dart';

class KingdomShiftTwinScreen extends StatelessWidget {
  const KingdomShiftTwinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KingdomShiftTwinController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Obx(() {
          final isScrollableState = controller.state.value == KingdomShiftTwinState.idle ||
              controller.state.value == KingdomShiftTwinState.error;
          if (isScrollableState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(children: [
                _buildHeader(),
                _buildBody(context, controller),
              ]),
            );
          }
          return Column(children: [
            _buildHeader(),
            Expanded(child: _buildBody(context, controller)),
          ]);
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFFFF006E).withValues(alpha: 0.2),
          Colors.transparent
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color(0xFFFF006E), Color(0xFF7B2FF7)]),
          ),
          child: const Icon(Icons.smart_display_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('KingdomShiftTwin',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Type it. Twin it. No camera needed.',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildBody(BuildContext context, KingdomShiftTwinController controller) {
    switch (controller.state.value) {
      case KingdomShiftTwinState.idle:
      case KingdomShiftTwinState.error:
        return _buildInputView(context, controller);
      case KingdomShiftTwinState.generating:
      case KingdomShiftTwinState.polling:
        return _buildLoadingView(controller);
      case KingdomShiftTwinState.ready:
        return _buildResultView(controller);
    }
  }

  Widget _buildInputView(BuildContext context, KingdomShiftTwinController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${controller.remainingToday.value} of 3 free videos left today',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          _buildAvatarPicker(controller),
          const SizedBox(height: 16),
          _buildBackgroundPicker(controller),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF12121E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: TextField(
              controller: controller.scriptController,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Type what you want your avatar to say...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          if (controller.errorText.value.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(controller.errorText.value,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                textAlign: TextAlign.center),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF006E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: controller.generate,
              child: const Text('Generate Video',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker(KingdomShiftTwinController controller) {
    return SizedBox(
      height: 76,
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.avatars.length + 1,
        itemBuilder: (_, i) {
          if (i == controller.avatars.length) {
            return GestureDetector(
              onTap: controller.isUploadingAvatar.value ? null : controller.uploadNewAvatar,
              child: Container(
                width: 60,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                ),
                child: controller.isUploadingAvatar.value
                    ? const Padding(
                        padding: EdgeInsets.all(18),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                      )
                    : const Icon(Icons.add_a_photo_outlined, color: Colors.white54),
              ),
            );
          }
          final avatar = controller.avatars[i];
          final heygenId = avatar['heygen_avatar_id'] as String;
          final selected = controller.selectedAvatarId.value == heygenId ||
              (controller.selectedAvatarId.value.isEmpty && i == 0);
          return GestureDetector(
            onTap: () => controller.selectAvatar(heygenId),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? const Color(0xFFFF006E) : Colors.white12, width: 2),
                image: DecorationImage(
                  image: NetworkImage(avatar['photo_url'] as String),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      )),
    );
  }

  Widget _buildBackgroundPicker(KingdomShiftTwinController controller) {
    return Obx(() {
      if (controller.backgroundImageUrl.value.isNotEmpty) {
        return Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(controller.backgroundImageUrl.value,
                width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          const Expanded(
              child: Text('Background image added',
                  style: TextStyle(color: Colors.white70, fontSize: 12))),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 18),
            onPressed: controller.clearBackgroundImage,
          ),
        ]);
      }
      return GestureDetector(
        onTap: controller.isUploadingBackground.value ? null : controller.uploadBackgroundImage,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF12121E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(children: [
            controller.isUploadingBackground.value
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))
                : const Icon(Icons.image_outlined, color: Colors.white54, size: 18),
            const SizedBox(width: 8),
            const Text('Add a product or background image (optional)',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
        ),
      );
    });
  }

  Widget _buildLoadingView(KingdomShiftTwinController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFFF006E)),
          const SizedBox(height: 20),
          Text(
            controller.state.value == KingdomShiftTwinState.generating
                ? 'Starting generation...'
                : 'Creating your video...\nThis usually takes 1-3 minutes',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(KingdomShiftTwinController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
          const SizedBox(height: 12),
          const Text('Your video is ready!',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(child: _VideoPreview(url: controller.videoUrl.value)),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF006E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: controller.useInPost,
              child: const Text('Use in a Post',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: controller.reset,
            child: const Text('Make Another', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  final String url;
  const _VideoPreview({required this.url});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller?.play();
        }
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF006E)));
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}
