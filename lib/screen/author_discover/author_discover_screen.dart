import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../widgets/ui_kit.dart';
import 'controller/author_discover_controller.dart';

class AuthorDiscoverScreen extends GetView<AuthorDiscoverController> {
  const AuthorDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: const Icon(AppIcons.arrowLeft)),
        title: const Text('Discover'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 4, 4, 10),
            child: Text('Writing Contests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          for (final ct in controller.contests)
            WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(AppIcons.medal, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(ct.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(ct.brief, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Prize ${ct.prize}',
                        style: const TextStyle(color: AppColors.star, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      Text('Ends ${ct.deadline}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                      const Spacer(),
                      PillButton(label: 'Join', filled: true, onTap: () => controller.join(ct)),
                    ],
                  ),
                  Obx(() {
                    final entries = controller.entries(ct);
                    if (entries.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Entered: ${entries.join(', ')}',
                        style: const TextStyle(fontSize: 12, color: AppColors.success),
                      ),
                    );
                  }),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 12, 4, 10),
            child: Text('Writing Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          WhiteCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (title, body) in controller.tips)
                  ListTile(
                    leading: const Icon(AppIcons.lightbulb, color: AppColors.primary),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(body, style: const TextStyle(fontSize: 13)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
