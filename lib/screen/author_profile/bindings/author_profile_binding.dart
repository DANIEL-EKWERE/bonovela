import 'package:get/get.dart';

import '../controller/author_profile_controller.dart';

class AuthorProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Tagged by author: an author's page can lead to another author's.
    final author = Get.arguments as String;
    Get.put(AuthorProfileController(author), tag: author);
  }
}
