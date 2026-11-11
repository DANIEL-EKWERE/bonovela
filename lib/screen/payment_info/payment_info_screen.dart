import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/payment_info_controller.dart';

class PaymentInfoScreen extends GetView<PaymentInfoController> {
  const PaymentInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Payment Info',
      body: Obx(() {
        if (controller.loading.value) return const LoadingView();
        controller.errors.length; // redraw field errors
        final bank = controller.isBank;
        Widget field(String key, String label, {String? hint, TextInputType? keyboard}) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextField(
            controller: controller.fields[key],
            keyboardType: keyboard,
            onChanged: (_) => controller.errors.remove(key),
            decoration: InputDecoration(labelText: '$label *', helperText: hint, errorText: controller.errors[key]),
          ),
        );
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(10)),
              child: const Text(
                'The account holder name must be your full legal name, exactly as it appears on your bank account. '
                'No third-party accounts can be used.',
                style: TextStyle(color: Color(0xFF9A5B00), fontSize: 13, height: 1.4),
              ),
            ),
            WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment method', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'bank', label: Text('Bank transfer')),
                      ButtonSegment(value: 'paypal', label: Text('PayPal')),
                    ],
                    selected: {controller.method.value},
                    onSelectionChanged: (s) => controller.method.value = s.first,
                  ),
                  const SizedBox(height: 16),
                  if (bank) ...[
                    field('country', 'Account country / region'),
                    const Text('Account currency', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'USD', label: Text('USD')),
                        ButtonSegment(value: 'NGN', label: Text('NGN')),
                      ],
                      selected: {controller.currency.value},
                      onSelectionChanged: (s) => controller.currency.value = s.first,
                    ),
                    const SizedBox(height: 14),
                    field('bank_name', 'Bank name'),
                    field('swift_code', 'SWIFT code / BIC'),
                  ],
                  field(
                    'account_detail',
                    bank ? 'Bank account number' : 'PayPal email',
                    keyboard: bank ? TextInputType.number : TextInputType.emailAddress,
                  ),
                  field(
                    'account_name',
                    'Name of account holder (legal name)',
                    hint: 'Full name exactly as it appears on the bank statement',
                  ),
                  if (bank) ...[
                    field('address', 'Address', hint: 'Should not be a PO or GPO box address'),
                    field('city', 'City'),
                    field('state', 'State / Province'),
                    field('postal_code', 'Postal code'),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
      bottom: Obx(() => GradientButton(label: 'Submit', loading: controller.saving.value, onTap: controller.submit)),
    );
  }
}
