import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/services/account_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    final onboarded = Get.find<AccountService>().onboarded;
    Future.delayed(
      const Duration(milliseconds: 1600),
      () => Get.offAllNamed(onboarded ? AppRoutes.main : AppRoutes.onboarding),
    );
  }
}
