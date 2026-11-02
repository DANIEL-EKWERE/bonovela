import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/language_controller.dart';
import '../../core/constants/app_icons.dart';

class LanguageScreen extends GetView<LanguageController> {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Language',
      background: Colors.white,
      body: Obx(
        () => ListView(
          children: [
            for (final l in LanguageController.languages)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: Text(l, style: const TextStyle(fontSize: 16)),
                trailing: Icon(
                  controller.picked.value == l ? AppIcons.checkCircleFill : AppIcons.radioOff,
                  color: controller.picked.value == l ? AppColors.primary : AppColors.divider,
                ),
                onTap: () => controller.picked.value = l,
              ),
          ],
        ),
      ),
      bottom: Obx(() => GradientButton(label: 'Select', onTap: controller.changed ? controller.select : null)),
    );
  }
}
