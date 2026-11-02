import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/author_models.dart';
import '../../../core/services/author_service.dart';
import '../../../widgets/ui_kit.dart';

class ChapterEditorController extends GetxController {
  final _author = Get.find<AuthorService>();

  late final AuthorStory story;
  late final AuthorChapter chapter;

  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final noteController = TextEditingController();

  final RxString body = ''.obs;
  final RxBool hasNote = false.obs;
  final RxBool autoPublish = false.obs;
  final RxBool isReleasing = false.obs;

  static const idealMin = 600;
  static const idealMax = 1000;

  int get words => AuthorStory.wordCount(body.value);
  bool get isPublished => chapter.status == ChapterStatus.published;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map;
    story = _author.story(args['storyId'] as String)!;
    final id = args['chapterId'] as String?;
    chapter = (id == null ? null : _author.chapter(id)) ?? _author.newChapter(story.id);
    titleController.text = chapter.title;
    bodyController.text = body.value = chapter.content;
    noteController.text = chapter.note;
    hasNote.value = chapter.note.isNotEmpty;
  }

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void _apply() {
    chapter
      ..title = titleController.text.trim()
      ..content = bodyController.text
      ..note = hasNote.value ? noteController.text.trim() : '';
  }

  bool get _isEmpty => titleController.text.trim().isEmpty && bodyController.text.trim().isEmpty;

  /// Back arrow: keep the work as a draft (or update the published chapter).
  void saveAndExit() {
    if (!_isEmpty) {
      _apply();
      _author.saveChapter(chapter);
      toast(isPublished ? 'Chapter updated' : 'Saved to drafts');
    }
    Get.back();
  }

  Future<void> release() async {
    if (words == 0) return toast('Write something first');
    isReleasing.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    _apply();
    _author.publishChapter(chapter);
    isReleasing.value = false;
    Get.back(); // release sheet
    Get.back(); // editor
    toast(autoPublish.value ? 'Scheduled' : 'Chapter released 🎉', 'Chapter ${chapter.label} of ${story.displayTitle}');
  }
}
