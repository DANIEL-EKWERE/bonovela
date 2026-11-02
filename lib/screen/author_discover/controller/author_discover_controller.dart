import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/data/author_data.dart';
import '../../../core/services/author_service.dart';
import '../../../widgets/ui_kit.dart';

/// Author-side Discover: writing contests and tips.
class AuthorDiscoverController extends GetxController {
  final _author = Get.find<AuthorService>();

  List<Contest> get contests => AuthorData.contests;
  List<(String, String)> get tips => AuthorData.writingTips;

  /// Titles of the author's stories entered in [contest].
  List<String> entries(Contest contest) {
    _author.stories.length;
    return _author.stories.where((s) => s.contests.contains(contest.id)).map((s) => s.displayTitle).toList();
  }

  /// Entering happens from a story's Novel Information.
  void join(Contest contest) {
    if (_author.stories.isEmpty) {
      Get.toNamed(AppRoutes.storyForm);
      toast('Create your story', 'Tick "${contest.title}" under Participate.');
    } else {
      toast('Enter from your story', 'Open a story → Edit → tick the contest under Participate.');
    }
  }
}
