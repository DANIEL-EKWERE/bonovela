import 'package:get/get.dart';

import '../controller/rewards_controller.dart';

class RewardsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RewardsController());
  }
}
