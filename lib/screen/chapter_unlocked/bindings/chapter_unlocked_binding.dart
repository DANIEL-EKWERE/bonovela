import 'package:get/get.dart';

import '../controller/chapter_unlocked_controller.dart';

class ChapterUnlockedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChapterUnlockedController());
  }
}
