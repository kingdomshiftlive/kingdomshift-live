import 'dart:io';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_divider.dart';
import 'package:shortzz/common/widget/privacy_policy_text.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/auth_screen/auth_screen_controller.dart';
import 'package:shortzz/screen/auth_screen/forget_password_sheet.dart';
import 'package:shortzz/screen/auth_screen/registration_screen.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthScreenController());
    if (kDebugMode) {
      controller.emailController.text = "kingdomshiftmedia@gmail.com";
      controller.passwordController.text = "@Test1234";
    }
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      resizeToAvoidBottomInset: false,
      body: Container(
        height: Get.height,
        decoration: const ShapeDecoration(
            shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.vertical(
              top: SmoothRadius(cornerRadius: 0, cornerSmoothing: 1)),
        )),
        child: Stack(
          children: [
            // const ThemeBlurBg(),
            SingleChildScrollView(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Image.asset(
                        AssetRes.logo,
                        width: 150,
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'KINGDOMSHIFT.LIVE',
                      style: TextStyle(
                        color: Color(0xFF00C9C8),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Equip · Empower · Expand',
                      style: TextStyle(
                        color: Color(0xFFC9A227),
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: LKey.signIn.tr.toUpperCase(),
                                  style: TextStyleCustom.unboundedBlack900(
                                    fontSize: 25,
                                    color: whitePure(context),
                                  ).copyWith(letterSpacing: -.2),
                                  children: const [],
                                )),
                          ),
                          const SizedBox(height: 30),
                          LoginSheetTextField(
                            hintText: LKey.enterYourEmail.tr,
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),
                          LoginSheetTextField(
                            isPasswordField: true,
                            hintText: LKey.enterPassword.tr,
                            controller: controller.passwordController,
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              decoration: BoxDecoration(
                                  color:
                                      whitePure(context).withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: InkWell(
                                onTap: () {
                                  Get.bottomSheet(const ForgetPasswordSheet(),
                                          isScrollControlled: true)
                                      .then((value) => controller
                                          .forgetEmailController
                                          .clear());
                                },
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 15),
                                    child: Text(LKey.forgetPassword.tr,
                                        style: TextStyleCustom.outFitRegular400(
                                            fontSize: 16,
                                            color: whitePure(context)))),
                              ),
                            ),
                          ),
                          TextButtonCustom(
                              onTap: controller.onLogin,
                              title: LKey.logIn.tr,
                              btnHeight: 50,
                              horizontalMargin: 0)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: InkWell(
                        onTap: () {
                          controller.fullNameController.clear();
                          controller.emailController.clear();
                          controller.passwordController.clear();
                          controller.confirmPassController.clear();
                          Get.to(() => const RegistrationScreen());
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                              color: whitePure(context).withValues(alpha: .2),
                              borderRadius: BorderRadius.circular(10.0)),
                          margin: const EdgeInsets.symmetric(vertical: 25),
                          alignment: Alignment.center,
                          child: Text(
                            LKey.createAccountHere.tr,
                            style: TextStyleCustom.outFitRegular400(
                                color: whitePure(context), fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomDivider(
                          color: whitePure(context),
                          height: .5,
                          width: 100,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            LKey.continueWith.tr,
                            style: TextStyleCustom.outFitRegular400(
                                fontSize: 16, color: whitePure(context)),
                          ),
                        ),
                        CustomDivider(
                          color: whitePure(context),
                          height: .5,
                          width: 100,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (Platform.isIOS)
                            SocialBtn(
                              onTap: controller.onAppleTap,
                              icon: AssetRes.icApple,
                            ),
                          if (Platform.isIOS) const SizedBox(width: 10),
                          SocialBtn(
                              onTap: controller.onGoogleTap,
                              icon: AssetRes.icGoogle),
                        ],
                      ),
                    ),
                    PrivacyPolicyText(
                      boldTextColor: whitePure(context),
                      regularTextColor:
                          whitePure(context).withValues(alpha: .8),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginSheetTextField extends StatefulWidget {
  final bool isPasswordField;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const LoginSheetTextField(
      {super.key,
      this.isPasswordField = false,
      required this.hintText,
      required this.controller,
      this.keyboardType});

  @override
  State<LoginSheetTextField> createState() => _LoginSheetTextFieldState();
}

class _LoginSheetTextFieldState extends State<LoginSheetTextField> {
  bool isHide = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
            side: BorderSide(color: whitePure(context).withValues(alpha: .4)),
            borderAlign: BorderAlign.inside,
          ),
          color: whitePure(context).withValues(alpha: .1)),
      child: TextField(
        controller: widget.controller,
        style: TextStyleCustom.outFitRegular400(
            color: whitePure(context), fontSize: 16),
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        obscureText: widget.isPasswordField && isHide,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: TextStyleCustom.outFitRegular400(
              color: whitePure(context), fontSize: 16),
          contentPadding: EdgeInsets.only(
              left: 10, right: 10, top: widget.isPasswordField ? 2 : 0),
          suffixIconConstraints: const BoxConstraints(),
          suffixIcon: widget.isPasswordField
              ? InkWell(
                  onTap: () {
                    isHide = !isHide;
                    setState(() {});
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Image.asset(
                        isHide ? AssetRes.icEye : AssetRes.icHideEye,
                        height: 24,
                        width: 35,
                        color: whitePure(context),
                        key: UniqueKey()),
                  ),
                )
              : null,
        ),
        cursorColor: whitePure(context),
      ),
    );
  }
}

class SocialBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const SocialBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 57,
        width: 57,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: whitePure(context)),
        alignment: Alignment.center,
        child: Image.asset(icon, height: 32, width: 32),
      ),
    );
  }
}
