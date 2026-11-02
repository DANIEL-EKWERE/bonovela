import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/author_models.dart';
import '../../../core/services/author_service.dart';
import '../../../widgets/ui_kit.dart';

class StoryChaptersController extends GetxController {
  final _author = Get.find<AuthorService>();

  late final String storyId;

  @override
  void onInit() {
    super.onInit();
    storyId = Get.arguments as String;
  }

  AuthorStory? get story => _author.story(storyId);

  /// Read inside Obx: touching [AuthorService.chapters] makes lists reactive.
  List<AuthorChapter> list(ChapterStatus status) {
    _author.chapters.length;
    return _author.chaptersOf(storyId, status);
  }

  void newChapter() {
    if (!(story?.isInfoComplete ?? false)) {
      toast('Complete your book information first');
      Get.toNamed(AppRoutes.storyForm, arguments: storyId);
      return;
    }
    Get.toNamed(AppRoutes.chapterEditor, arguments: {'storyId': storyId});
  }

  void edit(AuthorChapter c) =>
      Get.toNamed(AppRoutes.chapterEditor, arguments: {'storyId': storyId, 'chapterId': c.id});

  void editInfo() => Get.toNamed(AppRoutes.storyForm, arguments: storyId);

  void openStats() => Get.toNamed(AppRoutes.authorStatistics, arguments: storyId);

  void publish(AuthorChapter c) {
    _author.publishChapter(c);
    toast('Chapter published', 'Chapter ${c.label}');
  }

  void trash(AuthorChapter c) => _author.trashChapter(c);

  void restore(AuthorChapter c) => _author.restoreChapter(c);

  void deleteForever(AuthorChapter c) => _author.deleteChapterForever(c);
}
