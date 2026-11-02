import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/author_models.dart';
import '../../../core/services/author_service.dart';
import '../../../widgets/ui_kit.dart';

class AuthorStoriesController extends GetxController {
  final _author = Get.find<AuthorService>();

  final RxBool tipsExpanded = false.obs;

  RxList<AuthorStory> get stories => _author.stories;

  int chapterCount(AuthorStory s) => _author.published(s.id).length;
  int words(AuthorStory s) => _author.totalWords(s.id);

  /// Mock reader numbers: grow with published chapters.
  int views(AuthorStory s) => chapterCount(s) * 37;
  int likes(AuthorStory s) => chapterCount(s) * 3;

  DateTime lastUpdate(AuthorStory s) => s.updatedAt;

  void newStory() => Get.toNamed(AppRoutes.storyForm);

  void editStory(AuthorStory s) => Get.toNamed(AppRoutes.storyForm, arguments: s.id);

  void openChapters(AuthorStory s) => Get.toNamed(AppRoutes.storyChapters, arguments: s.id);

  void addChapter(AuthorStory s) => Get.toNamed(AppRoutes.chapterEditor, arguments: {'storyId': s.id});

  void deleteStory(AuthorStory s) {
    _author.deleteStory(s.id);
    toast('Story deleted', s.displayTitle);
  }
}
