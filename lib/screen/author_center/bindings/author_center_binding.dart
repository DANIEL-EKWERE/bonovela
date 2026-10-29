import 'package:get/get.dart';

import '../controller/author_center_controller.dart';

class AuthorCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthorCenterController());
  }
}
