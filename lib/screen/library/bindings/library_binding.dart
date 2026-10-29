import 'package:get/get.dart';

import '../controller/library_controller.dart';

class LibraryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LibraryController(), fenix: true);
  }
}
