import 'package:get/get.dart';

import '../controller/discover_controller.dart';

class DiscoverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DiscoverController(), fenix: true);
  }
}
