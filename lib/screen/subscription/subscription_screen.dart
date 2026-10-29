import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common.dart';
import 'controller/subscription_controller.dart';
import 'models/plan.dart';

class SubscriptionScreen extends GetView<SubscriptionController> {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(),
          Transform.translate(offset: const Offset(0, -40), child: _Plans()),
          _Benefits(),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Text(
              'RULES\n'
              '1. Your membership starts right after purchase and covers every short story.\n'
              '2. Novel chapters are still unlocked with coins.\n'
              '3. The subscription renews automatically at the same price for the same term until you cancel.\n'
              '4. You can cancel anytime from your store account settings.\n'
              '5. This is a demo: no payment is taken.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => GradientButton(
                    label: controller.isPlus
                        ? 'Extend · ${controller.selected.value.price}'
                        : 'Subscribe · ${controller.selected.value.price}',
                    loading: controller.isPaying.value,
                    onTap: controller.subscribe,
                  )),
              TextButton(
                onPressed: controller.restore,
                child: const Text('Restore purchases', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends GetView<SubscriptionController> {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + kToolbarHeight;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top, 20, 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A0A28), AppColors.plum, AppColors.plumLight],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final user = controller.user.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bonovela Plus',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  const Text('Unlimited reading of all short stories',
                      style: TextStyle(color: AppColors.blushDeep)),
                  const Text('Novel chapters are unlocked with coins.',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 14),
                  if (user != null)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primary,
                          child: Text(user.initial, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
                            Text(
                              controller.isPlus
                                  ? 'Active until ${Fmt.date(controller.plusUntil.value!)}'
                                  : 'ID ${user.id}',
                              style: TextStyle(
                                color: controller.isPlus ? AppColors.gold : Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              );
            }),
          ),
          const Icon(Icons.diamond_rounded, color: AppColors.blushDeep, size: 72),
        ],
      ),
    );
  }
}

class _Plans extends GetView<SubscriptionController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [for (final p in controller.plans) Expanded(child: _PlanCard(plan: p))],
      ),
    );
  }
}

class _PlanCard extends GetView<SubscriptionController> {
  final SubscriptionPlan plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) => Obx(() => _card(controller.selected.value.id == plan.id));

  Widget _card(bool selected) {
    final featured = plan.badge != null;
    return GestureDetector(
      onTap: () => controller.selected.value = plan,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.blush : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider, width: selected ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
        ),
        child: Column(
          children: [
            if (featured)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Text(plan.badge!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(6, featured ? 12 : 16, 6, 12),
              child: Column(
                children: [
                  Text(plan.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: featured ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: plan.price),
                      TextSpan(text: plan.period, style: const TextStyle(fontSize: 11)),
                    ]),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: featured ? 18 : 15,
                    ),
                  ),
                  if (plan.oldPrice != null)
                    Text(plan.oldPrice!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textHint, decoration: TextDecoration.lineThrough)),
                  const SizedBox(height: 8),
                  Text(plan.billing,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Benefits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.auto_stories_rounded, 'All Short Stories Free'),
      (Icons.block_rounded, 'No Ads in Short Stories'),
      (Icons.event_available_rounded, 'Cancel Anytime'),
    ];
    return Column(
      children: [
        const Text('— Membership Benefits —', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final (icon, label) in items)
              Expanded(
                child: Column(
                  children: [
                    Icon(icon, color: AppColors.primary),
                    const SizedBox(height: 6),
                    Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
