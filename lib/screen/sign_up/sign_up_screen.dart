import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/auth_sheet.dart';
import '../../widgets/common.dart';
import 'controller/sign_up_controller.dart';

class SignUpScreen extends GetView<SignUpController> {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthSheet(
      title: 'Sign up',
      subtitle: const Text(
        'This email address hasn\'t been signed up on Bonovela yet. Please sign up first.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      children: [
        const AuthLabel('Email address'),
        Text(controller.email, style: const TextStyle(color: AppColors.primary, fontSize: 16)),
        const SizedBox(height: 24),
        const AuthLabel('Password'),
        PasswordField(
          controller: controller.passwordController,
          hint: 'Enter password',
          obscure: controller.obscure,
          onChanged: (v) => controller.password.value = v,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final typed = controller.password.value.isNotEmpty;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final r in SignUpController.rules)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        typed && controller.passes(r) ? Icons.check_rounded : Icons.remove_rounded,
                        size: 16,
                        color: !typed
                            ? AppColors.textHint
                            : (controller.passes(r) ? AppColors.success : AppColors.error),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          r.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: !typed
                                ? AppColors.textHint
                                : (controller.passes(r) ? AppColors.success : AppColors.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 20),
        const AuthLabel('Confirm the password'),
        PasswordField(
          controller: controller.confirmController,
          hint: 'The same as the password above',
          obscure: controller.obscureConfirm,
          onChanged: (v) => controller.confirm.value = v,
        ),
        Obx(() => controller.confirm.value.isNotEmpty && !controller.matches
            ? const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Passwords don\'t match', style: TextStyle(color: AppColors.error, fontSize: 12)),
              )
            : const SizedBox.shrink()),
        const SizedBox(height: 16),
        Row(
          children: [
            Obx(() => Checkbox(
                  value: controller.agreed.value,
                  onChanged: (v) => controller.agreed.value = v ?? false,
                  activeColor: AppColors.primary,
                  shape: const CircleBorder(),
                )),
            Expanded(
              child: GestureDetector(
                onTap: controller.openTerms,
                child: const Text.rich(
                  TextSpan(
                    text: 'I accept the conditions of the ',
                    children: [
                      TextSpan(text: 'Terms of Use', style: TextStyle(color: AppColors.primary)),
                      TextSpan(text: ' and '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.primary)),
                    ],
                  ),
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Obx(() => GradientButton(
              label: 'Sign up',
              loading: controller.isSubmitting.value,
              onTap: controller.canSubmit ? controller.submit : null,
            )),
      ],
    );
  }
}
