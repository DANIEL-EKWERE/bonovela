import 'package:get/get.dart';

import '../controller/exchange_controller.dart';

class ExchangeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExchangeController());
  }
}
