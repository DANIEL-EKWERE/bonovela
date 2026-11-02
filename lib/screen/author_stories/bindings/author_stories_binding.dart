import 'package:get/get.dart';

import '../controller/author_stories_controller.dart';

class AuthorStoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthorStoriesController(), fenix: true);
  }
}
