import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

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
    final ({bool exists, bool verified}) status;
    try {
      status = await _account.emailStatus(value);
    } catch (_) {
      return toast("Couldn't reach Bonovela", 'Check your connection and try again.');
    } finally {
      isChecking.value = false;
    }
    if (!status.exists) {
      Get.toNamed(AppRoutes.signUp, arguments: value);
    } else if (!status.verified) {
      Get.toNamed(AppRoutes.verifyEmail, arguments: value);
    } else {
      Get.toNamed(AppRoutes.signIn, arguments: value);
    }
  }
}
