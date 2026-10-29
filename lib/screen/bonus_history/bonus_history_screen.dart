import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/bonus_history_controller.dart';

class BonusHistoryScreen extends GetView<BonusHistoryController> {
  const BonusHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Bonus Recpt & Exp History',
      actions: [
        IconButton(
          onPressed: () => Get.defaultDialog(
            title: 'About bonus',
            middleText: 'Bonus comes from rewards, check-ins and top-up packages. Each batch has an expiry '
                'date, and the soonest-expiring bonus is spent first.',
            textConfirm: 'OK',
            confirmTextColor: Colors.white,
            buttonColor: AppColors.primary,
            onConfirm: Get.back,
          ),
          icon: const Icon(Icons.help_outline_rounded),
        ),
      ],
      bottom: GradientButton(label: 'Get more bonus!', onTap: controller.getMore),
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                child: Text.rich(TextSpan(children: [
                  const TextSpan(text: 'Balance: '),
                  TextSpan(
                    text: '${controller.balance.value}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' Bonus'),
                ])),
              ),
              if (controller.records.isEmpty)
                const EmptyState(icon: Icons.stars_rounded, message: 'No bonus received yet.'),
              for (final r in controller.records)
                WhiteCard(
                  padding: EdgeInsets.zero,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => controller.toggle(r.id),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(r.source,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  ),
                                  Text('+${r.amount} Bonus', style: const TextStyle(fontSize: 15)),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('Received on: ${Fmt.date(r.receivedAt)}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ),
                                  Text(
                                    r.isExpired ? 'EXPIRED' : (r.remaining == 0 ? 'USED' : 'ACTIVE'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: r.isExpired
                                          ? AppColors.error
                                          : (r.remaining == 0 ? AppColors.textHint : AppColors.success),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('Expires on: ${Fmt.date(r.expiresAt)}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ),
                                  Icon(
                                    controller.expanded.contains(r.id)
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.textHint,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (controller.expanded.contains(r.id))
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.blush,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                for (final t in ['Consumed ${r.consumed}', 'Left ${r.remaining}', 'Expired ${r.expired}'])
                                  Expanded(
                                    child: Text(t, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.plum)),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}
