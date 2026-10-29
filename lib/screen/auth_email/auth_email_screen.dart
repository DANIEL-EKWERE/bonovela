import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/account_service.dart';
import '../../widgets/auth_sheet.dart';
import 'controller/auth_email_controller.dart';

class AuthEmailScreen extends GetView<AuthEmailController> {
  const AuthEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthSheet(
      title: 'Sign in or sign up',
      action: Obx(() => RoundActionButton(
            icon: Icons.arrow_forward_rounded,
            loading: controller.isChecking.value,
            onTap: controller.isValid ? controller.next : null,
          )),
      children: [
        const AuthLabel('Email address'),
        TextField(
          controller: controller.emailController,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (v) => controller.email.value = v,
          onSubmitted: (_) => controller.next(),
          decoration: InputDecoration(
            hintText: 'Please use a valid email address.',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Demo account: ${AccountService.demoEmail} · ${AccountService.demoPassword}',
          style: TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
      ],
    );
  }
}
