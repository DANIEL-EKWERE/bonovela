import 'package:get/get.dart';

import '../controller/contract_application_controller.dart';

class ContractApplicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ContractApplicationController());
  }
}
