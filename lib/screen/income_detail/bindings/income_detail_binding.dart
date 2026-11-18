import 'package:get/get.dart';

import '../controller/income_detail_controller.dart';

class IncomeDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IncomeDetailController());
  }
}
