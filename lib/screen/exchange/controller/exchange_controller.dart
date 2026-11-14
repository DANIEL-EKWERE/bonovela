import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

class ExchangeController extends GetxController {
  final _account = Get.find<AccountService>();

  final codeController = TextEditingController();
  final RxBool isRedeeming = false.obs;

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  Future<void> redeem() async {
    final code = codeController.text.trim();
    if (code.isEmpty) return toast('Enter a code');
    isRedeeming.value = true;
    final result = await _account.redeemCode(code).catchError((_) => const RedeemResult(error: 'offline'));
    isRedeeming.value = false;
    switch (result.error) {
      case 'offline':
        toast("Couldn't reach Bonovela", 'Check your connection and try again.');
      case 'used':
        toast('Already redeemed', 'Each code can only be used once.');
      case 'ineligible':
        toast("Code not available", result.message ?? "This code isn't available on your account.");
      case null:
        codeController.clear();
        toast('Code redeemed', result.vouchers > 0
            ? '+${result.vouchers} free chapter${result.vouchers == 1 ? '' : 's'} added to your wallet'
            : '+${result.bonus} bonus added to your wallet');
      default:
        toast('Invalid code', 'Check the code and try again.');
    }
  }
}
