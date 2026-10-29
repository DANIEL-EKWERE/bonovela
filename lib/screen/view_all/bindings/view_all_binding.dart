import 'package:get/get.dart';

import '../controller/view_all_controller.dart';

class ViewAllBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ViewAllController());
  }
}
