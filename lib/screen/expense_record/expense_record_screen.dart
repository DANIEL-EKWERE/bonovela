import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/wallet_models.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/expense_record_controller.dart';

class ExpenseRecordScreen extends GetView<ExpenseRecordController> {
  const ExpenseRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Expense Record',
      background: Colors.white,
      body: Obx(() {
        final items = controller.items;
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_rounded,
            message: 'The history will only show transactions within the last 30 days.',
          );
        }
        return ListView.separated(
          itemCount: items.length + 1,
          separatorBuilder: (_, _) => const Divider(indent: 16, endIndent: 16),
          itemBuilder: (_, i) {
            if (i == items.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Only the last 30 days are shown.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              );
            }
            final t = items[i];
            return ListTile(
              leading: Icon(
                t.kind == TxKind.gift ? Icons.volunteer_activism_rounded : Icons.lock_open_rounded,
                color: AppColors.primary,
              ),
              title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
              subtitle: Text(Fmt.date(t.date), style: const TextStyle(fontSize: 12)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (t.coins != 0) Text('${t.coins} coins', style: const TextStyle(color: AppColors.error)),
                  if (t.bonusUsed > 0)
                    Text('-${t.bonusUsed} bonus', style: const TextStyle(color: AppColors.error, fontSize: 12)),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
