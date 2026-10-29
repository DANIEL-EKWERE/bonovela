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
    await Future.delayed(const Duration(milliseconds: 600));
    final result = _account.redeem(code);
    isRedeeming.value = false;
    switch (result) {
      case -1:
        toast('Invalid code', 'Check the code and try again.');
      case 0:
        toast('Already redeemed', 'Each code can only be used once.');
      default:
        codeController.clear();
        toast('Code redeemed', '+$result bonus added to your wallet');
    }
  }
}
