import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/auto_subscription_controller.dart';

class AutoSubscriptionScreen extends GetView<AutoSubscriptionController> {
  const AutoSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Auto Subscription',
      background: Colors.white,
      body: Obx(() {
        final books = controller.books;
        if (books.isEmpty) {
          return const EmptyState(
            icon: Icons.autorenew_rounded,
            message: 'Novels you read or add to your library will appear here.',
          );
        }
        return ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Turn on auto-subscription to unlock the next chapter automatically when you reach it.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
            for (final b in books)
              ListTile(
                leading: BookCover(book: b, width: 40, radius: 3),
                title: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(b.author, style: const TextStyle(fontSize: 12)),
                trailing: Switch(value: controller.isOn(b.id), onChanged: (v) => controller.toggle(b.id, v)),
              ),
          ],
        );
      }),
    );
  }
}
