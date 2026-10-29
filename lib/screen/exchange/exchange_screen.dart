import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/exchange_controller.dart';

class ExchangeScreen extends GetView<ExchangeController> {
  const ExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Exchange',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Redeem a code', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 6),
                const Text('Enter a gift or promo code to get free bonus.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.codeController,
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => controller.redeem(),
                  decoration: const InputDecoration(
                    hintText: 'e.g. BONOVELA',
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => GradientButton(
                      label: 'Redeem',
                      width: double.infinity,
                      loading: controller.isRedeeming.value,
                      onTap: controller.redeem,
                    )),
              ],
            ),
          ),
          const Text(
            'Where to find codes: our social pages, events and partner promotions.\n'
            'Demo codes: BONOVELA, WELCOME20, PINKLOVE',
            style: TextStyle(fontSize: 12, color: AppColors.textHint, height: 1.6),
          ),
        ],
      ),
    );
  }
}
