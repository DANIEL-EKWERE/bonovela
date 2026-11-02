import 'package:get/get.dart';

import '../controller/author_discover_controller.dart';

class AuthorDiscoverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthorDiscoverController(), fenix: true);
  }
}
