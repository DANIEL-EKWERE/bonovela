import 'package:get/get.dart';

import '../controller/auth_email_controller.dart';

class AuthEmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthEmailController());
  }
}
