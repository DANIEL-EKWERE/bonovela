import 'package:get/get.dart';

import '../controller/push_settings_controller.dart';

class PushSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PushSettingsController());
  }
}
