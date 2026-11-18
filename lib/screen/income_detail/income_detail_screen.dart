import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/income_detail_controller.dart';

/// "Total Revenue" for one section: the books behind it, with Book ID,
/// story length and the approved amount.
class IncomeDetailScreen extends GetView<IncomeDetailController> {
  const IncomeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final money = IncomeDetailController.money;
    return SubPage(
      title: controller.label,
      body: Obx(() {
        if (controller.loading.value) return const LoadingView();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Text(controller.month, style: const TextStyle(fontSize: 20)),
                const Spacer(),
                Text(money(controller.total.value), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Latest update ${Fmt.date(DateTime.now())}',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
            const SizedBox(height: 16),
            for (final b in controller.books)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 76,
                        height: 101,
                        child: (b['cover'] ?? '').toString().isNotEmpty
                            ? CachedNetworkImage(imageUrl: b['cover'].toString(), fit: BoxFit.cover)
                            : Container(color: AppColors.surface),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b['title'].toString(), style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            'Book ID ${b['book_id']} · ${b['story_length']}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                          ),
                          const SizedBox(height: 12),
                          Text(controller.label, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                          Text(money((b['amount_cents'] as num).toInt()), style: const TextStyle(fontSize: 18)),
                          Text(
                            'Earning period: ${controller.month}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            for (final o in controller.others)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(o['reason']?.toString().isNotEmpty == true ? o['reason'].toString() : controller.label),
                subtitle: Text('Earning period: ${controller.month}'),
                trailing: Text(money((o['amount_cents'] as num).toInt())),
              ),
            if (controller.books.isEmpty && controller.others.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    'No ${controller.label} for this month yet.',
                    style: const TextStyle(color: AppColors.textHint),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
