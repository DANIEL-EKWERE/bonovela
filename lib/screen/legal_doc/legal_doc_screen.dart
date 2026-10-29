import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/ui_kit.dart';
import 'controller/legal_doc_controller.dart';

class LegalDocScreen extends GetView<LegalDocController> {
  const LegalDocScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: controller.title,
      background: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const Text('Last updated: October 2026', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
          for (final (heading, body) in controller.sections) ...[
            const SizedBox(height: 20),
            Text(heading, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(height: 1.6, color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
