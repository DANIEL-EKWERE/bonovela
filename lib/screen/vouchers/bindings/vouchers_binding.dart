import 'package:get/get.dart';

import '../controller/vouchers_controller.dart';

class VouchersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VouchersController());
  }
}
