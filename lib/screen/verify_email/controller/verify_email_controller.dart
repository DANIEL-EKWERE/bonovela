import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

/// "Great! Now, only one step to go." The real app would open the mail app;
/// here "Jump to email box" stands in for tapping Confirm in that email.
class VerifyEmailController extends GetxController {
  final _account = Get.find<AccountService>();

  late final String email;
  final RxBool isVerifying = false.obs;
  final RxInt resendIn = 0.obs;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments as String;
  }

  Future<void> openMailbox() async {
    isVerifying.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    _account.verifyEmail(email);
    isVerifying.value = false;
    AppRoutes.closeAuth();
    toast('Email confirmed 🎉', 'Welcome to Bonovela, ${_account.user.value?.name ?? ''}');
  }

  Future<void> resend() async {
    if (resendIn.value > 0) return;
    toast('Email sent', 'We\'ve sent another confirmation link to $email');
    for (resendIn.value = 30; resendIn.value > 0; resendIn.value--) {
      await Future.delayed(const Duration(seconds: 1));
      if (isClosed) return;
    }
  }
}
