import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/auth_sheet.dart';
import '../../widgets/common.dart';
import 'controller/verify_email_controller.dart';

class VerifyEmailScreen extends GetView<VerifyEmailController> {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthSheet(
      title: 'Great!\nNow, only one step to go.',
      subtitle: Text.rich(
        TextSpan(
          text: 'Please check your email box at ',
          children: [
            TextSpan(text: controller.email, style: const TextStyle(color: AppColors.primary)),
            const TextSpan(text: ' and tap Confirm to complete signing up.'),
          ],
        ),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5),
      ),
      children: [
        const SizedBox(height: 48),
        const Center(child: Icon(Icons.mark_email_unread_outlined, size: 84, color: AppColors.blushDeep)),
        const SizedBox(height: 48),
        Obx(() => GradientButton(
              label: 'Jump to email box',
              loading: controller.isVerifying.value,
              onTap: controller.openMailbox,
            )),
        const SizedBox(height: 14),
        SizedBox(
          height: 48,
          child: TextButton(
            onPressed: Get.back,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              shape: const StadiumBorder(),
            ),
            child: const Text('Back', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Obx(() => TextButton(
                onPressed: controller.resendIn.value > 0 ? null : controller.resend,
                child: Text(
                  controller.resendIn.value > 0
                      ? 'Resend in ${controller.resendIn.value}s'
                      : 'Didn\'t get it? Resend email',
                  style: TextStyle(
                    color: controller.resendIn.value > 0 ? AppColors.textHint : AppColors.primary,
                  ),
                ),
              )),
        ),
        const Text(
          'Demo: "Jump to email box" confirms the email straight away.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
      ],
    );
  }
}
