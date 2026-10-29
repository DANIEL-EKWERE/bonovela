import 'package:get/get.dart';

import '../controller/online_service_controller.dart';

class OnlineServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OnlineServiceController());
  }
}
