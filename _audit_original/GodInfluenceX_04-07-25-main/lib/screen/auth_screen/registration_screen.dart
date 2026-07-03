import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/privacy_policy_text.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/auth_screen/auth_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

import '../../common/widget/theme_blur_bg.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthScreenController>();
    if (kDebugMode) {
      controller.emailController.text = "kartikghosh770@yopmail.com";
      controller.confirmPassController.text = "@Test1234";
    }
    return Scaffold(
      body: Stack(
        children: [
          const ThemeBlurBg(),
          SizedBox(
            height: Get.height,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    CustomBackButton(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      color: whitePure(context),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                        child: SingleChildScrollView(
                      dragStartBehavior: DragStartBehavior.down,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, right: 20, top: 50, bottom: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(LKey.signUp.tr.replaceAll('&', '').toUpperCase(),
                                    style: TextStyleCustom.unboundedBlack900(
                                      fontSize: 25,
                                      color: whitePure(context),
                                    ).copyWith(letterSpacing: -.2)),
                                // GradientText(LKey.startJourney.tr.toUpperCase(),
                                //     gradient: StyleRes.themeGradient,
                                //     style: TextStyleCustom.unboundedBlack900(
                                //       fontSize: 25,
                                //       color: textDarkGrey(context),
                                //     ).copyWith(letterSpacing: -.2)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),

                          LoginSheetTextField(
                            hintText: LKey.fullName.tr,
                            controller: controller.fullNameController,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // TextFieldCustom(
                          //   controller: controller.fullNameController,
                          //   title: LKey.fullName.tr,
                          // ),
                          LoginSheetTextField(
                            hintText: LKey.email.tr,
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(
                            height: 20,
                          ),

                          // TextFieldCustom(
                          //   controller: controller.emailController,
                          //   title: LKey.email.tr,
                          //   keyboardType: TextInputType.emailAddress,
                          // ),

                          LoginSheetTextField(
                            hintText: LKey.password.tr,
                            isPasswordField: true,
                            controller: controller.passwordController,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // TextFieldCustom(
                          //   controller: controller.passwordController,
                          //   title: LKey.password.tr,
                          //   isPasswordField: true,
                          // ),
                          LoginSheetTextField(
                            controller: controller.confirmPassController,
                            hintText: LKey.reTypePassword.tr,
                            isPasswordField: true,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // TextFieldCustom(
                          //   controller: controller.confirmPassController,
                          //   title: LKey.reTypePassword.tr,
                          //   isPasswordField: true,
                          // ),
                          Obx(() => Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: whitePure(context),
                                ),
                                child: CheckboxListTile(
                                  value: controller.ageCheckbox.value,
                                  onChanged: (value) => controller.ageCheckbox.value = value ?? false,
                                  title: Text(
                                    "I confirm that I am at least 18 years old",
                                    style: TextStyleCustom.outFitLight300(fontSize: 14, color: whitePure(context)),
                                  ),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: themeAccentSolid(context),
                                  checkColor: whitePure(context),
                                ),
                              )),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )),
                    TextButtonCustom(
                        onTap: controller.onCreateAccount,
                        title: LKey.createAccount.tr,
                        backgroundColor: textDarkGrey(context),
                        horizontalMargin: 5,
                        titleColor: whitePure(context)),
                    SizedBox(height: AppBar().preferredSize.height / 1.2),
                    const SafeArea(top: false, maintainBottomViewPadding: true, child: PrivacyPolicyText()),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
