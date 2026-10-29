import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/gems_controller.dart';

class GemsScreen extends GetView<GemsController> {
  const GemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 170,
            backgroundColor: AppColors.blushDeep,
            leading: IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back_rounded)),
            title: const Text('Gems Details'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.blushDeep, Color(0xFFD9ECFF)]),
                ),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Obx(() => Text('${controller.gems.value}',
                        style: const TextStyle(fontSize: 34, color: AppColors.primary, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 8),
                    const Text('Gems left', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const CurrencyIcon('gems', size: 64),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverList.list(
              children: [
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('How to get gems?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 12),
                      _Way(
                        title: 'Reading task',
                        amount: 1,
                        detail: 'Get 1 gem for 30 minutes of reading every day.',
                        action: 'GO',
                        onTap: controller.goRead,
                      ),
                      const SizedBox(height: 10),
                      _Way(
                        title: 'Top up',
                        amount: 3,
                        detail: 'Every time you top up any amount, you get 3 gems.',
                        action: 'TOP UP',
                        onTap: controller.goTopUp,
                      ),
                      const SizedBox(height: 12),
                      const Text('Gems will be used to vote for and gift your favourite stories.',
                          style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
                WhiteCard(
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('History', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          if (controller.history.isEmpty)
                            const SizedBox(
                              height: 180,
                              child: EmptyState(icon: Icons.diamond_outlined, message: 'No records'),
                            ),
                          for (final g in controller.history)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(g.source),
                              subtitle: Text(Fmt.date(g.date), style: const TextStyle(fontSize: 12)),
                              trailing: Text('+${g.amount}',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Way extends StatelessWidget {
  final String title;
  final int amount;
  final String detail;
  final String action;
  final VoidCallback onTap;

  const _Way({required this.title, required this.amount, required this.detail, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    const CurrencyIcon('gems', size: 16),
                    Text(' +$amount', style: const TextStyle(color: Color(0xFF3FB8E6))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          PillButton(label: action, filled: true, onTap: onTap),
        ],
      ),
    );
  }
}
