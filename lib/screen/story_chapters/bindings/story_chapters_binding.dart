import 'package:get/get.dart';

import '../controller/story_chapters_controller.dart';

class StoryChaptersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StoryChaptersController());
  }
}
