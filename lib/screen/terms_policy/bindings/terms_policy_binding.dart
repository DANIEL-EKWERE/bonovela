import 'package:get/get.dart';

import '../controller/terms_policy_controller.dart';

class TermsPolicyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TermsPolicyController());
  }
}
