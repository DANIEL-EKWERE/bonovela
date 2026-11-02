import 'package:get/get.dart';

import '../controller/drama_controller.dart';

class DramaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DramaController(), fenix: true);
  }
}
