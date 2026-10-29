import 'package:get/get.dart';

import '../controller/short_controller.dart';

class ShortBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ShortController(), fenix: true);
  }
}
