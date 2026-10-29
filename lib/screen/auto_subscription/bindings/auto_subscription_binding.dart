import 'package:get/get.dart';

import '../controller/auto_subscription_controller.dart';

class AutoSubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AutoSubscriptionController());
  }
}
