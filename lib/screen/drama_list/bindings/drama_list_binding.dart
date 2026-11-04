import 'package:get/get.dart';

import '../controller/drama_list_controller.dart';

class DramaListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DramaListController());
  }
}
