import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/audio_live_stream_screen/create_audio_live_screen/create_audio_live_stream_controller.dart';

import '../../../common/widget/gradient_text.dart';
import '../../../languages/languages_keys.dart';
import '../../../utilities/style_res.dart';
import '../../../utilities/text_style_custom.dart';
import '../../../utilities/theme_res.dart';

class CreateAudioLiveStreamScreen extends StatelessWidget {
  final CreateAudioLiveStreamController controller = Get.put(CreateAudioLiveStreamController());

  CreateAudioLiveStreamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: const Icon(Icons.clear)),
        title: const Text('Create Audio Live Stream'), // Placeholder for LKey.createAudioLive
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   'Enter Stream Title', // Placeholder for LKey.enterStreamTitle
            //   style: TextStyle(color: Colors.white, fontSize: 16),
            // ),
            const SizedBox(height: 8),
            Container(
              height: 75,
              decoration: ShapeDecoration(
                color: whitePure(context).withValues(alpha: .15),
                shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
                    side: BorderSide(color: whitePure(context).withValues(alpha: .18), width: 1)),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: controller.titleController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: LKey.enterLiveStreamTitle.tr,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    hintStyle:
                        TextStyleCustom.outFitLight300(fontSize: 17, color: whitePure(context).withValues(alpha: .7))),
                expands: true,
                maxLines: null,
                minLines: null,
                keyboardType: TextInputType.text,
                style: TextStyleCustom.outFitRegular400(color: whitePure(context), fontSize: 17),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: controller.createLiveStream,
              child: Container(
                height: 53,
                decoration: ShapeDecoration(
                    shape:
                        SmoothRectangleBorder(borderRadius: SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1)),
                    color: whitePure(context)),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                child: GradientText(
                  gradient: StyleRes.themeGradient,
                  'Start Audio Live'.tr,
                  style: TextStyleCustom.unboundedMedium500(fontSize: 17),
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: ,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.blue,
            //     minimumSize: const Size(double.infinity, 50),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            //   child: const Text(
            //     'Start Audio Live', // Placeholder for LKey.startAudioLive
            //     style: TextStyle(color: Colors.white, fontSize: 16),
            //   ),
            // ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
