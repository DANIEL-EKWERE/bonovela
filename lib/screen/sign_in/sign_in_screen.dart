import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/auth_sheet.dart';
import 'controller/sign_in_controller.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthSheet(
      title: 'Sign in',
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Please fill in the password of the email address.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 4),
          Text(controller.email, style: const TextStyle(color: AppColors.primary, fontSize: 16)),
        ],
      ),
      action: Obx(() => RoundActionButton(
            icon: Icons.check_rounded,
            loading: controller.isSubmitting.value,
            onTap: controller.password.value.isEmpty ? null : controller.submit,
          )),
      children: [
        PasswordField(
          controller: controller.passwordController,
          hint: 'Password',
          obscure: controller.obscure,
          onChanged: controller.onChanged,
          onSubmitted: (_) => controller.submit(),
        ),
        Obx(() => controller.error.value.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(controller.error.value, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              )),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: controller.forgotPassword,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('Forgot Password ?', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ),
      ],
    );
  }
}
