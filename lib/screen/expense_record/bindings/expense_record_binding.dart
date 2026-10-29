import 'package:get/get.dart';

import '../controller/expense_record_controller.dart';

class ExpenseRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExpenseRecordController());
  }
}
