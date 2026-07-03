import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/auth_screen/auth_screen_controller.dart';
import 'package:shortzz/screen/term_and_privacy_screen/term_and_privacy_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class PrivacyPolicyText extends StatelessWidget {
  final Color? regularTextColor;
  final Color? boldTextColor;

  const PrivacyPolicyText(
      {super.key, this.regularTextColor, this.boldTextColor});

  @override
  Widget build(BuildContext context) {
    AuthScreenController authController = Get.put(AuthScreenController());
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: ThemeData(
            checkboxTheme: const CheckboxThemeData(
              // shape: CircleBorder(),
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            ),
          ),
          child: Obx(
            () => Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: authController.checkBox.value,
                onChanged: (value) {
                  authController.checkBox.value = value ?? false;
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: LKey.agreeToPolicy.tr,
                style: TextStyleCustom.outFitRegular400(
                    color: regularTextColor ?? textLightGrey(context)),
                children: [
                  TextSpan(
                      text: '\n${LKey.privacyPolicy.tr}',
                      style: TextStyleCustom.outFitSemiBold600(
                          color: boldTextColor ?? textLightGrey(context)),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(() => const TermAndPrivacyScreen(
                              type: TermAndPrivacyType.privacyPolicy));
                        }),
                  TextSpan(
                      text: ' ${LKey.andText.tr} ',
                      style: TextStyleCustom.outFitRegular400(
                          color: regularTextColor ?? textLightGrey(context))),
                  TextSpan(
                      text: LKey.termsOfUse.tr,
                      style: TextStyleCustom.outFitSemiBold600(
                          color: boldTextColor ?? textLightGrey(context)),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(() => const TermAndPrivacyScreen(
                              type: TermAndPrivacyType.termAndCondition));
                        }),
                ]),
          ),
        ),
      ],
    );
  }
}
