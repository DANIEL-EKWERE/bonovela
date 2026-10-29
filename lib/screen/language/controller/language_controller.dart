import 'package:get/get.dart';

import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

class LanguageController extends GetxController {
  final _account = Get.find<AccountService>();

  static const languages = [
    'English',
    'Français',
    'Bahasa Indonesia',
    'Filipino',
    'ภาษาไทย',
    '한국어',
    '日本語',
    'Deutsch',
    '繁體中文',
    'Español',
    'Português',
    'Türkçe',
  ];

  late final RxString picked;

  @override
  void onInit() {
    super.onInit();
    picked = _account.language.value.obs;
  }

  bool get changed => picked.value != _account.language.value;

  void select() {
    _account.setLanguage(picked.value);
    Get.back();
    // Book content is English-only in the mock catalogue.
    toast('Language set to ${picked.value}');
  }
}
