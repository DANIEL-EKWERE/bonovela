import 'package:get/get.dart';

import '../controller/payment_info_controller.dart';

class PaymentInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PaymentInfoController());
  }
}
