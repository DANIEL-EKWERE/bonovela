import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/wallet_controller.dart';

class WalletScreen extends GetView<WalletController> {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Transaction History', AppRoutes.transactionHistory),
      ('Bonus Receipt & Expiry History', AppRoutes.bonusHistory),
      ('Chapter Unlocked', AppRoutes.chapterUnlocked),
      ('Expense Record', AppRoutes.expenseRecord),
      ('Auto Subscription', AppRoutes.autoSubscription),
    ];
    return SubPage(
      title: 'Wallet',
      background: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.blush, AppColors.blushDeep]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _Balance(label: 'Coins', kind: 'coins', value: controller.coins),
                    const SizedBox(width: 12),
                    _Balance(
                      label: 'Bonus',
                      kind: 'bonus',
                      value: controller.bonus,
                      onTap: () => controller.open(AppRoutes.bonusHistory),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GradientButton(label: 'TOP UP', width: double.infinity, onTap: controller.topUp),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final (title, route) in items) MenuTile(title: title, onTap: () => controller.open(route)),
          const SizedBox(height: 16),
          const Text(
            'Coins are bought with real money and never expire. Bonus is earned from rewards and '
            'expires; it is always spent before coins.',
            style: TextStyle(fontSize: 12, color: AppColors.textHint, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Balance extends StatelessWidget {
  final String label;
  final String kind;
  final RxInt value;
  final VoidCallback? onTap;

  const _Balance({required this.label, required this.kind, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 92,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Stack(
            children: [
              Positioned(right: -8, bottom: -8, child: Opacity(opacity: 0.12, child: CurrencyIcon(kind, size: 64))),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => Text('${value.value}',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700))),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
                        if (onTap != null)
                          const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textHint),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
