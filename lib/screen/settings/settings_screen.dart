import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common.dart';
import 'controller/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget row(String title, {String? value, Widget? trailing, VoidCallback? onTap}) => ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null) Text(value, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
              ?trailing,
              if (trailing == null) const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: const Icon(Icons.close_rounded)),
      ),
      body: Obx(() => ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text('Settings', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              ),
              row('Language Setting', value: controller.language.value, onTap: () => controller.open(AppRoutes.language)),
              row('Push Management', onTap: () => controller.open(AppRoutes.pushSettings)),
              row(
                'Clear Cache',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${controller.cacheMb.value.toStringAsFixed(2)}MB',
                        style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: controller.clearCache,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
                        child: const Text('clean', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
              row('Rate Us', onTap: controller.rateUs),
              row('Terms and Policy', onTap: () => controller.open(AppRoutes.termsPolicy)),
              row('Join Us', onTap: controller.joinUs),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Version 1.0.0', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              ),
            ],
          )),
      bottomNavigationBar: controller.isLoggedIn
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(48, 8, 48, 16),
                child: GradientButton(label: 'Logout', onTap: controller.logout),
              ),
            )
          : null,
    );
  }
}
