import 'package:get/get.dart';

import '../controller/author_calendar_controller.dart';

class AuthorCalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthorCalendarController(), fenix: true);
  }
}
