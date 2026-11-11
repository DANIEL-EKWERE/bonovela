import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/services/account_service.dart';
import '../../../core/services/ads_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _go();
  }

  /// Splash for at least 1.6s, then an open-screen ad if Marketing has one
  /// this device hasn't seen (first-time users go to onboarding first).
  Future<void> _go() async {
    final onboarded = Get.find<AccountService>().onboarded;
    final next = onboarded ? AppRoutes.main : AppRoutes.onboarding;
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 1600)),
      onboarded ? Get.find<AdsService>().nextUnseen(AdsService.splash) : Future.value(null),
    ]);
    final ad = results[1] as AdBanner?;
    ad == null ? Get.offAllNamed(next) : Get.offAllNamed(AppRoutes.openAd, arguments: {'ad': ad, 'next': next});
  }
}
