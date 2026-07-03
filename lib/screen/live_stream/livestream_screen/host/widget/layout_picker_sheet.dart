import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/haptic_manager.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LayoutPickerSheet extends StatelessWidget {
  final LivestreamScreenController controller;

  const LayoutPickerSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: ShapeDecoration(
            color: whitePure(context),
            shape: const SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.vertical(
                top: SmoothRadius(cornerRadius: 30, cornerSmoothing: 1),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: .5,
                  color: textLightGrey(context),
                  width: 100,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                LKey.changeLayout.tr,
                style: TextStyleCustom.unboundedRegular400(
                  fontSize: 16,
                  color: textDarkGrey(context),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                final currentLayout = controller.liveData.value.streamLayout ??
                    StreamLayout.spotlight;
                return GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.75,
                  children: StreamLayout.values.map((layout) {
                    final isSelected = layout == currentLayout;
                    return _LayoutOption(
                      layout: layout,
                      isSelected: isSelected,
                      onTap: () {
                        HapticManager.shared.light();
                        controller.changeStreamLayout(layout);
                        Get.back();
                      },
                    );
                  }).toList(),
                );
              }),
              SizedBox(height: AppBar().preferredSize.height),
            ],
          ),
        ),
      ],
    );
  }
}

class _LayoutOption extends StatelessWidget {
  final StreamLayout layout;
  final bool isSelected;
  final VoidCallback onTap;

  const _LayoutOption({
    required this.layout,
    required this.isSelected,
    required this.onTap,
  });

  String get _label {
    switch (layout) {
      case StreamLayout.spotlight:
        return LKey.layoutSpotlight.tr;
      case StreamLayout.grid:
        return LKey.layoutGrid.tr;
      case StreamLayout.stack:
        return LKey.layoutStack.tr;
      case StreamLayout.focus:
        return LKey.layoutFocus.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: ShapeDecoration(
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
                  side: BorderSide(
                    color: isSelected
                        ? themeAccentSolid(context)
                        : textLightGrey(context).withValues(alpha: .3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                gradient: isSelected ? StyleRes.themeGradient : null,
                color: isSelected ? null : bgMediumGrey(context),
              ),
              child: _buildLayoutPreview(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _label,
            style: TextStyleCustom.outFitMedium500(
              fontSize: 11,
              color: isSelected
                  ? themeAccentSolid(context)
                  : textDarkGrey(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutPreview(BuildContext context) {
    final Color c1 = isSelected
        ? Colors.white.withValues(alpha: .4)
        : textLightGrey(context).withValues(alpha: .3);
    final Color c2 = isSelected
        ? Colors.white.withValues(alpha: .25)
        : textLightGrey(context).withValues(alpha: .2);

    switch (layout) {
      case StreamLayout.spotlight:
        // Host large left, small grid right
        return Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(flex: 2, child: _cell(c1, 100)),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _cell(c2, 4)),
                    const SizedBox(height: 2),
                    Expanded(child: _cell(c2, 4)),
                  ],
                ),
              ),
            ],
          ),
        );
      case StreamLayout.grid:
        // Equal grid
        return Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _cell(c1, 4)),
                    const SizedBox(width: 2),
                    Expanded(child: _cell(c2, 4)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _cell(c2, 4)),
                    const SizedBox(width: 2),
                    Expanded(child: _cell(c1, 4)),
                  ],
                ),
              ),
            ],
          ),
        );
      case StreamLayout.stack:
        // Vertical stack
        return Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Expanded(child: _cell(c1, 4)),
              const SizedBox(height: 2),
              Expanded(child: _cell(c2, 4)),
            ],
          ),
        );
      case StreamLayout.focus:
        // 1 large top, 2 small bottom
        return Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Expanded(flex: 2, child: _cell(c1, 4)),
              const SizedBox(height: 2),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _cell(c2, 4)),
                    const SizedBox(width: 2),
                    Expanded(child: _cell(c2, 4)),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _cell(Color color, double radius) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius > 10 ? 6 : 3),
      ),
    );
  }
}
