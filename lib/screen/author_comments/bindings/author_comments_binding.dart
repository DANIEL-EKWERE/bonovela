import 'package:get/get.dart';

import '../controller/author_comments_controller.dart';

class AuthorCommentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthorCommentsController(), fenix: true);
  }
}
