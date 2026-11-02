import 'package:get/get.dart';

import '../controller/story_form_controller.dart';

class StoryFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StoryFormController());
  }
}
