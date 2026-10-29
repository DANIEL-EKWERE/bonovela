import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/services/account_service.dart';

/// "Sign in or sign up": one email field. Known emails go to the password
/// step, new ones to sign up.
class AuthEmailController extends GetxController {
  final _account = Get.find<AccountService>();

  final emailController = TextEditingController();
  final RxString email = ''.obs;
  final RxBool isChecking = false.obs;

  bool get isValid => GetUtils.isEmail(email.value.trim());

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> next() async {
    if (!isValid) return;
    final value = email.value.trim().toLowerCase();
    isChecking.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    isChecking.value = false;
    if (!_account.hasAccount(value)) {
      Get.toNamed(AppRoutes.signUp, arguments: value);
    } else if (!_account.isVerified(value)) {
      Get.toNamed(AppRoutes.verifyEmail, arguments: value);
    } else {
      Get.toNamed(AppRoutes.signIn, arguments: value);
    }
  }
}
