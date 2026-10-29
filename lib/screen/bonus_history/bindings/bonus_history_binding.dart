import 'package:get/get.dart';

import '../controller/bonus_history_controller.dart';

class BonusHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BonusHistoryController());
  }
}
