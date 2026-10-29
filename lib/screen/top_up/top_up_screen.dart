import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/top_up_controller.dart';
import 'models/coin_package.dart';

class TopUpScreen extends GetView<TopUpController> {
  const TopUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Top Up',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WhiteCard(
            child: Obx(() => Row(
                  children: [
                    const Text('Balance', style: TextStyle(color: AppColors.textSecondary)),
                    const Spacer(),
                    const CurrencyIcon('coins'),
                    const SizedBox(width: 4),
                    Text('${controller.coins.value}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 16),
                    const CurrencyIcon('bonus'),
                    const SizedBox(width: 4),
                    Text('${controller.bonus.value}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                )),
          ),
          GestureDetector(
            onTap: controller.openSubscription,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.plum, AppColors.plumLight]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.diamond_rounded, color: AppColors.blushDeep),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Bonovela Plus — unlimited short stories',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
          const Text('Choose a package', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
            children: [for (final p in controller.packages) _PackageTile(package: p)],
          ),
          const SizedBox(height: 20),
          const Text(
            '• Coins unlock chapters and never expire.\n'
            '• Bonus from packages expires after 30 days.\n'
            '• Every top-up also earns 3 gems.\n'
            '• This is a demo: no payment is taken.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.7),
          ),
        ],
      ),
      bottom: Obx(() => GradientButton(
            label: 'Pay ${controller.selected.value.price}',
            onTap: () => _showCheckout(context),
          )),
    );
  }

  void _showCheckout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            final p = controller.selected.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text('${p.coins} coins${p.bonus > 0 ? ' + ${p.bonus} bonus' : ''}',
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                RadioGroup<String>(
                  groupValue: controller.method.value,
                  onChanged: (v) => controller.method.value = v!,
                  child: Column(
                    children: [
                      for (final m in controller.methods)
                        RadioListTile<String>(
                          value: m,
                          title: Text(m),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GradientButton(
                  label: 'Pay ${p.price}',
                  width: double.infinity,
                  loading: controller.isPaying.value,
                  onTap: controller.pay,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _PackageTile extends GetView<TopUpController> {
  final CoinPackage package;

  const _PackageTile({required this.package});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selected.value.id == package.id;
      return GestureDetector(
        onTap: () => controller.selected.value = package,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: selected ? AppColors.blush : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 1.5),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CurrencyIcon('coins', size: 26),
                    const SizedBox(height: 4),
                    Text('${package.coins}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    if (package.bonus > 0)
                      Text('+${package.bonus} bonus',
                          style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                    const SizedBox(height: 6),
                    Text(package.price, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            if (package.tag != null)
              Positioned(
                top: -6,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                  child: Text(package.tag!, style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
          ],
        ),
      );
    });
  }
}
