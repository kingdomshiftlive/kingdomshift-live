import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/functions/debounce_action.dart';
import 'package:shortzz/common/manager/firebase_notification_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/common_service.dart';
import 'package:shortzz/common/service/api/notification_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';
import 'package:shortzz/languages/dynamic_translations.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/user_model/user_model.dart' as user;
import 'package:shortzz/screen/dashboard_screen/dashboard_screen.dart';

class AuthScreenController extends BaseController {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController forgetEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  RxBool checkBox = false.obs;
  RxBool ageCheckbox = false.obs;

  @override
  void onInit() {
    CommonService.instance.fetchGlobalSettings();
    FirebaseNotificationManager.instance;
    super.onInit();
  }

  Future<void> onLogin() async {
    if (emailController.text.trim().isEmpty) {
      return showSnackBar(LKey.enterEmail.tr);
    }
    if (passwordController.text.trim().isEmpty) {
      return showSnackBar(LKey.enterAPassword.tr);
    }
    showLoader();
    String? fullname;
    if (GetUtils.isEmail(emailController.text.trim())) {
      UserCredential? credential = await signInWithEmailAndPassword();
      if (credential != null) {
        if (credential.user?.emailVerified == false) {
          stopLoader();
          return showSnackBar(LKey.verifyEmailFirst.tr);
        }
        fullname = credential.user?.displayName;
      } else {
        return showSnackBar('user not found');
      }
    }

    user.User? data = await _registration(
        identity: emailController.text.trim(),
        loginMethod: LoginMethod.email,
        fullname: fullname ?? emailController.text.split('@')[0]);
    stopLoader();
    if (data != null) {
      _navigateScreen(data);
    }
  }

  Future<void> onCreateAccount() async {
    if (fullNameController.text.trim().isEmpty) {
      return showSnackBar(LKey.fullNameEmpty.tr);
    }
    if (emailController.text.trim().isEmpty) {
      return showSnackBar(LKey.enterEmail.tr);
    }
    if (passwordController.text.trim().isEmpty) {
      return showSnackBar(LKey.enterAPassword.tr);
    }
    if (confirmPassController.text.trim().isEmpty) {
      return showSnackBar(LKey.confirmPasswordEmpty.tr);
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      return showSnackBar(LKey.invalidEmail.tr);
    }
    if (passwordController.text.trim() != confirmPassController.text.trim()) {
      return showSnackBar(LKey.passwordMismatch.tr);
    }
    if (!ageCheckbox.value) {
      return showSnackBar("You must be at least 18 years old to create an account.");
    }
    showLoader();
    UserCredential? credential = await createUserWithEmailAndPassword();
    if (credential != null) {
      await _registration(
          identity: emailController.text.trim(),
          loginMethod: LoginMethod.email,
          fullname: fullNameController.text.trim());
      credential.user?.updateDisplayName(fullNameController.text.trim());
      credential.user?.sendEmailVerification();
      Get.back();
      Get.back();
      showSnackBar(LKey.verificationLinkSent.tr);
    }
  }

  void onGoogleTap() async {
    showLoader();
    UserCredential? credential;
    try {
      credential = await signInWithGoogle();
    } catch (e) {
      Loggers.error(e);
      Get.back();
    }

    if (credential?.user == null) return;
    user.User? data = await _registration(
        identity: credential?.user?.email ?? '',
        loginMethod: LoginMethod.google,
        fullname: credential?.user?.displayName ?? credential?.user?.email?.split('@')[0]);
    Get.back();
    if (data != null) {
      _navigateScreen(data);
    }
  }

  void onAppleTap() async {
    showLoader();
    UserCredential? credential;
    try {
      credential = await signInWithApple();
    } catch (e) {
      Loggers.error(e);
      Get.back();
    }
    if (credential?.user == null) return;
    user.User? data = await _registration(
        identity: credential?.user?.email ?? 'apple_${DateTime.now().millisecondsSinceEpoch}',
        loginMethod: LoginMethod.apple,
        fullname: credential?.user?.displayName ?? credential?.user?.email?.split('@')[0]);
    Get.back();
    if (data != null) {
      _navigateScreen(data);
    }
  }

  Future<user.User?> _registration(
      {required String identity, required LoginMethod loginMethod, String? fullname}) async {
    String? deviceToken = await FirebaseNotificationManager.instance.getNotificationToken();
    if (deviceToken == null) return null;

    user.User? userData = await UserService.instance.logInUser(
        identity: identity,
        loginMethod: loginMethod,
        deviceToken: deviceToken,
        fullName: (fullname == null || fullname.trim().isEmpty == true)
            ? "${DateTime.now().millisecondsSinceEpoch}"
            : fullname);

    Setting? setting = SessionManager.instance.getSettings();
    if (userData?.newRegister == true && setting?.registrationBonusStatus == 1) {
      final translations = Get.find<DynamicTranslations>();
      final languageData = translations.keys[userData?.appLanguage] ?? {};
      NotificationService.instance.pushNotification(
          title: languageData[LKey.registrationBonusTitle] ?? LKey.registrationBonusTitle.tr,
          body: languageData[LKey.registrationBonusDescription] ?? LKey.registrationBonusDescription.tr,
          type: NotificationType.other,
          deviceType: userData?.device,
          token: userData?.deviceToken,
          authorizationToken: userData?.token?.authToken);
    }
    SubscriptionManager.shared.login('${userData?.id}');
    if (userData != null) {
      // Subscribe My Following Ids For Live streaming notification
      return userData;
    }
    return null;
  }

  Future<UserCredential?> createUserWithEmailAndPassword() async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());
      SessionManager.instance.setPassword(passwordController.text.trim());
      return credential;
    } on FirebaseAuthException catch (e) {
      stopLoader();
      Loggers.error(e.message);
      if (e.code == 'weak-password') {
        showSnackBar(LKey.weakPassword.tr);
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(LKey.accountExists.tr);
      } else {
        showSnackBar(e.message);
      }
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword() async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());
      return credential;
    } on FirebaseAuthException catch (e) {
      stopLoader();
      if (e.code == 'user-not-found') {
        showSnackBar(LKey.noUserFound.tr);
        Loggers.info(LKey.noUserFound.tr);
      } else if (e.code == 'wrong-password') {
        showSnackBar(LKey.incorrectPassword.tr);
        Loggers.info(LKey.incorrectPassword.tr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    final authenticate = await googleSignIn.authenticate();
    return await FirebaseAuth.instance
        .signInWithCredential(GoogleAuthProvider.credential(idToken: authenticate.authentication.idToken));

    // Trigger the authentication flow
    // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // // Obtain the auth details from the request
    // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // // Create a new credential
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth?.accessToken,
    //   idToken: googleAuth?.idToken,
    // );

    // Once signed in, return the UserCredential
    // return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    return await FirebaseAuth.instance.signInWithProvider(appleProvider);
  }

  void forgetPassword() async {
    final email = forgetEmailController.text.trim();
    if (email.isEmpty) {
      showSnackBar(LKey.enterEmail.tr);
      return;
    }
    showLoader();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      stopLoader();
      Get.back(); // Close the BottomSheet
      showSnackBar(LKey.resetPasswordLinkSent.tr);
    } on FirebaseAuthException catch (e) {
      stopLoader();
      showSnackBar(e.message ?? "An error occurred. Please try again.");
    }
  }

  void _navigateScreen(user.User? data) {
    DebounceAction.shared.call(() async {
      SessionManager.instance.setLogin(true);
      SessionManager.instance.setUser(data);
      Get.offAll(() => DashboardScreen(myUser: data));
    }, milliseconds: 250);
  }
}
