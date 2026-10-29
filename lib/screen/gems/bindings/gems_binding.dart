import 'package:get/get.dart';

import '../controller/gems_controller.dart';

class GemsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GemsController());
  }
}
