import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

/// "Great! Now, only one step to go." The account activates from the link
/// emailed by noreply@bonovela.com; then the reader signs in.
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

  /// "I've confirmed": check the account is active, then sign in.
  Future<void> openMailbox() async {
    isVerifying.value = true;
    if (!Get.isRegistered<ApiClient>()) {
      // Sample-data builds: confirm on the spot.
      await Future.delayed(const Duration(milliseconds: 900));
      _account.verifyEmail(email);
      isVerifying.value = false;
      AppRoutes.closeAuth();
      return toast('Email confirmed 🎉', 'Welcome to Bonovela, ${_account.user.value?.name ?? ''}');
    }
    try {
      final status = await _account.emailStatus(email);
      isVerifying.value = false;
      if (!status.verified) {
        return toast('Not activated yet', 'Tap the link in the email from noreply@bonovela.com, then try again.');
      }
      Get.offNamed(AppRoutes.signIn, arguments: email);
      toast('Account activated 🎉', 'Sign in with your password.');
    } catch (_) {
      isVerifying.value = false;
      toast("Couldn't reach Bonovela", 'Check your connection and try again.');
    }
  }

  Future<void> resend() async {
    if (resendIn.value > 0) return;
    await _account.resendVerification(email);
    toast('Email sent', 'We\'ve sent another confirmation link to $email');
    for (resendIn.value = 30; resendIn.value > 0; resendIn.value--) {
      await Future.delayed(const Duration(seconds: 1));
      if (isClosed) return;
    }
  }
}
