import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/wallet_models.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/transaction_history_controller.dart';

class TransactionHistoryScreen extends GetView<TransactionHistoryController> {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Transaction History',
      body: Obx(() {
        final items = controller.items;
        if (items.isEmpty) {
          return const EmptyState(icon: Icons.receipt_long_rounded, message: 'No transactions yet.');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final t = items[i];
            return WhiteCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    switch (t.kind) {
                      TxKind.subscription => Icons.diamond_rounded,
                      TxKind.reward => Icons.card_giftcard_rounded,
                      _ => Icons.account_balance_wallet_rounded,
                    },
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${Fmt.date(t.date)}${t.price.isNotEmpty ? ' · ${t.price}' : ''}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  if (t.coins != 0)
                    Text('+${t.coins}',
                        style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
