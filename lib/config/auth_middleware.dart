import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../core/services/account_service.dart';
import 'routes.dart';

/// Sends signed-out users to the sign-in landing for account-only screens.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<AccountService>().isLoggedIn ? null : const RouteSettings(name: AppRoutes.login);
}
