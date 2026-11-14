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
      title: controller.withdrawMode ? 'Withdraw' : 'Payment Info',
      body: Obx(() {
        if (controller.loading.value) return const LoadingView();
        controller.errors.length; // redraw field errors
        final bank = controller.isBank;
        Widget field(String key, String label, {String? hint, TextInputType? keyboard, bool optional = false}) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextField(
                controller: controller.fields[key],
                keyboardType: keyboard,
                onChanged: (_) => controller.errors.remove(key),
                decoration: InputDecoration(
                  labelText: optional ? '$label (optional)' : '$label *',
                  helperText: hint,
                  helperMaxLines: 2,
                  errorText: controller.errors[key],
                ),
              ),
            );
        Widget notice(String title, String text) => Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            border: Border.all(color: const Color(0xFFF1D9A6)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF5A4300)),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        );
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (controller.withdrawMode) ...[
              WhiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Amount', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextField(
                      controller: controller.amount,
                      enabled: controller.canWithdraw.value,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => controller.errors.remove('amount'),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(prefixText: '\$ ', errorText: controller.errors['amount']),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Available Balance: ${PaymentInfoController.money(controller.available.value)}\n'
                      'Amount must be at least ${PaymentInfoController.money(controller.minimum.value)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                    if (controller.placedThisMonth.value)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "You've placed this month's withdrawal. You can place the next one next month.",
                          style: TextStyle(fontSize: 13, color: AppColors.error),
                        ),
                      )
                    else if (controller.available.value < controller.minimum.value)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'You can withdraw once your available balance reaches '
                          '${PaymentInfoController.money(controller.minimum.value)}.',
                          style: const TextStyle(fontSize: 13, color: AppColors.error),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
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
                    const Text('Transfer method', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 6, bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'SWIFT\nInternational bank transfer · Your bank may charge a receiving fee · 0–3 business days',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
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
                    field(
                      'intermediary_swift',
                      'Intermediary bank SWIFT code / BIC',
                      optional: true,
                      hint: 'Typically only necessary if your bank told you to use an intermediary bank',
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 10),
                      child: Text('Recipient', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                    field(
                      'nickname',
                      'Nickname',
                      optional: true,
                      hint: 'For reference only. Not sent to the recipient.',
                    ),
                    field('email', 'Email address', optional: true, keyboard: TextInputType.emailAddress),
                    field('address', 'Address', hint: 'Should not be a PO or GPO box address'),
                    field('city', 'City'),
                    field('state', 'State / Province'),
                    field('postal_code', 'Postal code'),
                  ],
                ],
              ),
            ),
            if (controller.withdrawMode) ...[
              notice(
                'Withdrawal Date',
                'Withdrawals can be made at any time during the month, but each person is limited to one '
                    'withdrawal per month.',
              ),
              notice(
                'Withdrawal Processing Time',
                'Withdrawals are processed on the 11th of each month, covering the requests from the previous month '
                    '(e.g. on 11 November, the withdrawals placed from 11 October to 10 November are processed and '
                    'paid).',
              ),
            ],
          ],
        );
      }),
      bottom: Obx(
        () => controller.withdrawMode
            ? Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      label: 'SUBMIT',
                      loading: controller.saving.value,
                      onTap: controller.canWithdraw.value ? controller.submit : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.manageAccounts,
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                      child: const Text('Manage Payment Accounts', textAlign: TextAlign.center),
                    ),
                  ),
                ],
              )
            : GradientButton(label: 'Submit', loading: controller.saving.value, onTap: controller.submit),
      ),
    );
  }
}
