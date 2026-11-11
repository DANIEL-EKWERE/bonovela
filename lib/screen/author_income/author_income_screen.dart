import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/ui_kit.dart';
import 'controller/author_income_controller.dart';

class AuthorIncomeScreen extends GetView<AuthorIncomeController> {
  const AuthorIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: const Icon(AppIcons.arrowLeft)),
        title: const Text('Income'),
        actions: [IconButton(onPressed: controller.help, icon: const Icon(AppIcons.help))],
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                border: Border.all(color: const Color(0xFFF1D9A6)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text.rich(
                TextSpan(
                  style: TextStyle(color: Color(0xFF9A5B00), fontSize: 13, height: 1.4),
                  children: [
                    TextSpan(
                      text: '⚠️ IMPORTANT NOTICE: ',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text:
                          'Bonovela conducts regular content quality checks. Low-quality, plagiarized, or AI-generated '
                          'spam content may result in contract termination, forfeiture of unpaid earnings, and recovery '
                          'of previously paid fees. Please maintain our quality standards.',
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total Revenue:  ${AuthorIncomeController.money(controller.totalRevenue)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                PillButton(label: 'Payment Info', filled: true, onTap: controller.paymentInfo),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: controller.prevMonth, icon: const Icon(AppIcons.back, size: 18)),
                Text(controller.monthLabel, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                IconButton(onPressed: controller.nextMonth, icon: const Icon(AppIcons.chevronRight, size: 18)),
              ],
            ),
            Row(
              children: [
                const Text('Month Revenue', style: TextStyle(color: AppColors.textSecondary)),
                const Spacer(),
                Text(
                  AuthorIncomeController.money(controller.monthTotal),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 14),
              child: Text(
                'Latest update at ${Fmt.date(DateTime.now())}',
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ),
            for (final (name, from, to) in controller.types)
              _IncomeCard(
                title: name,
                amount: AuthorIncomeController.money(controller.amountFor(name)),
                colors: [Color(from), Color(to)],
                onTap: () => controller.openType(name),
              ),
          ],
        ),
      ),
    );
  }
}

class _IncomeCard extends StatelessWidget {
  final String title;
  final String amount;
  final List<Color> colors;
  final VoidCallback onTap;

  const _IncomeCard({required this.title, required this.amount, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 112,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
                        const Spacer(),
                        Text(
                          amount,
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const Icon(AppIcons.chevronRight, color: Colors.white70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
