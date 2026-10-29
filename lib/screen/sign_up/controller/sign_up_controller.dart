import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

class PasswordRule {
  final String label;
  final bool Function(String) test;

  const PasswordRule(this.label, this.test);
}

class SignUpController extends GetxController {
  final _account = Get.find<AccountService>();

  late final String email;
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final RxString password = ''.obs;
  final RxString confirm = ''.obs;
  final RxBool obscure = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxBool agreed = false.obs;
  final RxBool isSubmitting = false.obs;

  static final rules = [
    PasswordRule('Within 6–18 characters', (p) => p.length >= 6 && p.length <= 18),
    PasswordRule(
      'Must include both numbers and letters, can include underscores',
      (p) => RegExp(r'[A-Za-z]').hasMatch(p) && RegExp(r'\d').hasMatch(p),
    ),
    PasswordRule('No other special characters or signs', (p) => RegExp(r'^[A-Za-z0-9_]*$').hasMatch(p)),
  ];

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments as String;
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }

  bool passes(PasswordRule r) => r.test(password.value);
  bool get passwordOk => rules.every(passes);
  bool get matches => confirm.value.isNotEmpty && confirm.value == password.value;
  bool get canSubmit => passwordOk && matches && agreed.value;

  Future<void> submit() async {
    if (!passwordOk) return toast('Password doesn\'t meet the rules');
    if (!matches) return toast('Passwords don\'t match');
    if (!agreed.value) return toast('Please accept the Terms of Use and Privacy Policy');
    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    _account.register(email, password.value);
    isSubmitting.value = false;
    Get.offNamed(AppRoutes.verifyEmail, arguments: email);
  }

  void openTerms() => Get.toNamed(AppRoutes.termsPolicy);
}
