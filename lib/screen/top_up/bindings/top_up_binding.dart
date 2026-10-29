import 'package:get/get.dart';

import '../controller/top_up_controller.dart';

class TopUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TopUpController());
  }
}
