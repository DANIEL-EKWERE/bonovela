import 'package:get/get.dart';

import '../controller/author_income_controller.dart';

class AuthorIncomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthorIncomeController(), fenix: true);
  }
}
