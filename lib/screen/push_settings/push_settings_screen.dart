import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/ui_kit.dart';
import 'controller/push_settings_controller.dart';

class PushSettingsScreen extends GetView<PushSettingsController> {
  const PushSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Push Management',
      body: Obx(() => ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              for (final (i, (key, title, subtitle)) in PushSettingsController.items.indexed) ...[
                Container(
                  color: Colors.white,
                  child: SwitchListTile(
                    value: controller.push[key] ?? true,
                    onChanged: (v) => controller.set(key, v),
                    title: Text(title, style: const TextStyle(fontSize: 16)),
                    subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
                  ),
                ),
                if (i == 0) const SizedBox(height: 12),
              ],
            ],
          )),
    );
  }
}
