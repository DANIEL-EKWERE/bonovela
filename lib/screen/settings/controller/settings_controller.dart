import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

class SettingsController extends GetxController {
  final _account = Get.find<AccountService>();

  RxString get language => _account.language;
  RxDouble get cacheMb => _account.cacheMb;
  bool get isLoggedIn => _account.isLoggedIn;

  void open(String route) => Get.toNamed(route);

  void clearCache() {
    _account.clearCache();
    toast('Cache cleared');
  }

  void rateUs() => toast('Thanks for your support 💗', 'The store page opens here in the release build.');

  void joinUs() => toast('Join us', 'Write to careers@bonovela.app');

  void logout() {
    Get.defaultDialog(
      title: 'Log out?',
      middleText: 'Your library stays on this device.',
      textCancel: 'Cancel',
      textConfirm: 'Log out',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFEC2A82),
      cancelTextColor: const Color(0xFF6E6A75),
      onConfirm: () {
        _account.logout();
        Get.until((r) => r.settings.name == AppRoutes.main);
        toast('Logged out');
      },
    );
  }
}
