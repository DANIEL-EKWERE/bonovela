import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

/// Sign-in landing. Offers the last account used on this device, social
/// sign-in, and the email flow.
class AuthController extends GetxController {
  final _account = Get.find<AccountService>();

  final RxString loadingProvider = ''.obs;
  final RxBool agreed = true.obs;

  Rxn<Map> get lastAccount => _account.lastAccount;

  bool _checkTerms() {
    if (!agreed.value) toast('Please accept the Terms of Use and Privacy Policy');
    return agreed.value;
  }

  Future<void> social(String provider) async {
    if (!_checkTerms()) return;
    loadingProvider.value = provider;
    await Future.delayed(const Duration(milliseconds: 800));
    _account.socialLogin(provider);
    loadingProvider.value = '';
    AppRoutes.closeAuth();
    toast('Welcome', _account.user.value?.name ?? '');
  }

  void email() {
    if (_checkTerms()) Get.toNamed(AppRoutes.authEmail);
  }

  /// "Continue as …" on the remembered account.
  void continueLast() {
    final last = lastAccount.value;
    if (last == null) return;
    final provider = last['provider']?.toString() ?? 'email';
    if (provider == 'email') {
      Get.toNamed(AppRoutes.signIn, arguments: last['email']);
    } else {
      social(provider);
    }
  }

  void useAnother() => _account.forgetLastAccount();

  void openTerms() => Get.toNamed(AppRoutes.termsPolicy);
}
