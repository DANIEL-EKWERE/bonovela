import 'package:get/get.dart';

import '../../author_calendar/bindings/author_calendar_binding.dart';
import '../../author_comments/bindings/author_comments_binding.dart';
import '../../author_income/bindings/author_income_binding.dart';
import '../../author_stories/bindings/author_stories_binding.dart';
import '../controller/author_center_controller.dart';

/// Author Center shell plus its five tabs (Stories, Discover, Calendar,
/// Comments, Income).
class AuthorCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthorCenterController());
    AuthorStoriesBinding().dependencies();
    AuthorCalendarBinding().dependencies();
    AuthorCommentsBinding().dependencies();
    AuthorIncomeBinding().dependencies();
  }
}
