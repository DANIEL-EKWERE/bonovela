import 'package:get/get.dart';

import '../controller/author_statistics_controller.dart';

class AuthorStatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthorStatisticsController());
  }
}
