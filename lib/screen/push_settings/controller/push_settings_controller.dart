import 'package:get/get.dart';

import '../../../core/services/account_service.dart';

class PushSettingsController extends GetxController {
  final _account = Get.find<AccountService>();

  RxMap<String, bool> get push => _account.push;

  static const items = [
    ('all', 'All Notifications', 'Turn every push notification on or off'),
    ('chapters', 'Chapters Updated', 'New chapters from books in your library'),
    ('activities', 'Activities', 'Events, rewards and offers'),
  ];

  void set(String key, bool on) => _account.setPush(key, on);
}
