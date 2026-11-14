import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/withdrawals_controller.dart';

class WithdrawalsScreen extends GetView<WithdrawalsController> {
  const WithdrawalsScreen({super.key});

  static String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  static Color _color(String status) => switch (status) {
    'Successful' => AppColors.success,
    'Processing' => AppColors.primary,
    'Pending' => const Color(0xFFC78100),
    _ => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Withdrawal history',
      body: Obx(() {
        if (controller.loading.value) return const LoadingView();
        if (controller.failed.value) {
          return EmptyState(
            icon: AppIcons.searchOff,
            message: "Couldn't load your withdrawals.",
            actionLabel: 'Retry',
            onAction: controller.load,
          );
        }
        if (controller.rows.isEmpty) {
          return EmptyState(
            icon: AppIcons.wallet,
            message: 'No withdrawals yet.',
            actionLabel: 'Withdraw',
            onAction: controller.withdraw,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: controller.rows.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              if (i == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('Tap a withdrawal to see its details.', style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              final w = controller.rows[i - 1];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  onTap: () => _details(w),
                  title: Text(
                    _money(w.requestedCents),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                  subtitle: Text('${w.category} · ${Fmt.date(w.createdAt)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StatusChip(w.status, _color(w.status)),
                      const Icon(AppIcons.chevronRight, color: AppColors.textHint),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _details(WithdrawalRecord w) {
    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(k, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    final note = switch (w.status) {
      'Successful' => 'This payment was sent successfully.',
      'Processing' => 'Approved — the transfer is being processed.',
      'Pending' => 'Waiting to be processed on the 11th.',
      _ => "The transfer didn't go through. The amount is back in your available balance; check your payment info.",
    };
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(w.category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              const Text('Amount requested', style: TextStyle(color: AppColors.textSecondary)),
              Text(_money(w.requestedCents), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              _StatusChip(w.status, _color(w.status)),
              const Divider(height: 28),
              row('Requested on', Fmt.date(w.createdAt)),
              if (w.approvedCents != null) row('Amount approved', _money(w.approvedCents!)),
              if (w.paidAt != null) row('Paid on', Fmt.date(w.paidAt!)),
              if (w.reference.isNotEmpty) row('Payment reference', w.reference),
              if (w.paidTo.isNotEmpty) row('Paid to', w.paidTo),
              const SizedBox(height: 8),
              Text(note, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}
