import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'bindings/tip_binding.dart';
import 'controller/tip_controller.dart';

/// Opens the Vote / Gift sheet for [bookId]. [initialTab]: 0 vote, 1 gift.
Future<void> showTipSheet(BuildContext context, String bookId, {int initialTab = 1}) async {
  final binding = TipBinding(bookId)..dependencies();
  Get.find<TipController>(tag: bookId).tab.value = initialTab;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _TipSheet(bookId: bookId),
  );
  binding.dispose();
}

class _TipSheet extends GetView<TipController> {
  final String bookId;

  const _TipSheet({required this.bookId});

  @override
  String? get tag => bookId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TabLabel('Vote', active: controller.tab.value == 0, onTap: () => controller.tab.value = 0),
                        const SizedBox(width: 32),
                        _TabLabel('Gift', active: controller.tab.value == 1, onTap: () => controller.tab.value = 1),
                      ],
                    ),
                  ),
                  IconButton(onPressed: Get.back, icon: const Icon(AppIcons.close)),
                ],
              ),
            ),
            if (controller.tab.value == 1) _GiftTab(bookId: bookId) else _VoteTab(bookId: bookId),
          ],
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabLabel(this.label, {required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    ),
  );
}

/// "+N" ticket badge: votes that go to the book.
class _VoteBadge extends StatelessWidget {
  final int votes;

  const _VoteBadge(this.votes);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: AppColors.voucher, borderRadius: BorderRadius.circular(6)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(AppIcons.voucher, size: 11, color: Colors.white),
        const SizedBox(width: 2),
        Text(
          '+$votes',
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _GiftTab extends GetView<TipController> {
  final String bookId;

  const _GiftTab({required this.bookId});

  @override
  String? get tag => bookId;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const _VoteBadge(1),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'This icon means votes for the book are sent along with your gift.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: c.gifts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              // Fixed height fits emoji + name + price at any width.
              mainAxisExtent: 124,
            ),
            itemBuilder: (_, i) {
              final g = c.gifts[i];
              final selected = c.giftIndex.value == i;
              return GestureDetector(
                onTap: () => c.selectGift(i),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.blush : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(g.emoji, style: const TextStyle(fontSize: 36)),
                            const SizedBox(height: 4),
                            Text(g.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text(
                              '${Fmt.thousands(g.price)} coins',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(top: -6, right: 6, child: _VoteBadge(g.votes)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          GradientButton(
            label: c.canAffordGift
                ? 'Send ${c.gift.name} · ${Fmt.thousands(c.gift.price)} coins'
                : 'Balance is low · Top up',
            width: double.infinity,
            loading: c.isSending.value,
            onTap: c.sendGift,
          ),
          const SizedBox(height: 8),
          Text(
            'Coins Balance ${c.coins.value} Coins + ${c.bonus.value} Bonus',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _VoteTab extends GetView<TipController> {
  final String bookId;

  const _VoteTab({required this.bookId});

  @override
  String? get tag => bookId;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final have = c.vouchers.value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.voucher.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(AppIcons.voucher, size: 36, color: AppColors.voucher),
          ),
          const SizedBox(height: 12),
          Text(
            c.book.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text('${Fmt.thousands(c.bookVotes)} votes this week', style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          if (have > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final n in TipController.voteSteps)
                  if (n <= have)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text('$n'),
                        selected: c.voteCount.value == n,
                        onSelected: (_) => c.setVotes(n),
                        showCheckmark: false,
                        selectedColor: AppColors.blush,
                        labelStyle: TextStyle(color: c.voteCount.value == n ? AppColors.primary : null),
                      ),
                    ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text('All ($have)'),
                    selected: c.voteCount.value == have,
                    onSelected: (_) => c.setVotes(have),
                    showCheckmark: false,
                    selectedColor: AppColors.blush,
                    labelStyle: TextStyle(color: c.voteCount.value == have ? AppColors.primary : null),
                  ),
                ),
              ],
            )
          else
            const Text(
              'You have no vouchers yet. Earn them by reading 30 minutes a day or topping up.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          const SizedBox(height: 20),
          GradientButton(
            label: have > 0 ? 'Vote ${c.voteCount.value}' : 'Get vouchers',
            width: double.infinity,
            loading: c.isSending.value,
            onTap: c.vote,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CurrencyIcon('voucher', size: 14),
              const SizedBox(width: 4),
              Text('Your vouchers: $have', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
