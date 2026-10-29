import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

class SignInController extends GetxController {
  final _account = Get.find<AccountService>();

  late final String email;
  final passwordController = TextEditingController();
  final RxString password = ''.obs;
  final RxBool obscure = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments as String;
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }

  void onChanged(String v) {
    password.value = v;
    error.value = '';
  }

  Future<void> submit() async {
    if (password.value.isEmpty) return;
    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    final result = _account.signIn(email, password.value);
    isSubmitting.value = false;
    if (result != null) {
      error.value = result;
      return;
    }
    AppRoutes.closeAuth();
    toast('Welcome back', _account.user.value?.name ?? '');
  }

  void forgotPassword() {
    Get.defaultDialog(
      title: 'Reset password',
      middleText: 'We\'ll send a link to $email so you can choose a new password.',
      textCancel: 'Cancel',
      textConfirm: 'Send link',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFEC2A82),
      cancelTextColor: const Color(0xFF6E6A75),
      onConfirm: () {
        Get.back();
        toast('Reset link sent', 'Check $email');
      },
    );
  }
}
