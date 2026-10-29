import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/inbox_controller.dart';

class InboxScreen extends GetView<InboxController> {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Inbox',
      actions: [
        TextButton(
          onPressed: controller.markAllRead,
          child: const Text('Read all', style: TextStyle(color: AppColors.primary)),
        ),
      ],
      body: Obx(() {
        final list = controller.messages;
        if (list.isEmpty) return const EmptyState(icon: Icons.mail_outline_rounded, message: 'No messages yet.');
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final m = list[i];
            return Dismissible(
              key: ValueKey(m.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => controller.delete(m),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
              ),
              child: GestureDetector(
                onTap: () => controller.open(m),
                child: WhiteCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.blush,
                            child: Icon(Icons.notifications_rounded, color: AppColors.primary),
                          ),
                          if (!m.read)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(m.title,
                                      style: TextStyle(
                                          fontWeight: m.read ? FontWeight.w500 : FontWeight.w700, fontSize: 15)),
                                ),
                                Text(Fmt.ago(m.date), style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(m.body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                            if (m.bookId != null)
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Text('Read now ›', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
