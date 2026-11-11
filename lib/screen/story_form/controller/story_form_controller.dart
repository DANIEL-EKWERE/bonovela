import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/data/author_data.dart';
import '../../../core/models/author_models.dart';
import '../../../core/services/author_service.dart';
import '../../../widgets/ui_kit.dart';

/// "Novel Information" — three steps: basics, details, review.
/// Edits a working copy and only writes to [AuthorService] on Skip/Complete.
class StoryFormController extends GetxController {
  final _author = Get.find<AuthorService>();

  late final AuthorStory story;
  late final bool isNew;

  /// 0 basics · 1 details · 2 review
  final RxInt step = 0.obs;

  final titleController = TextEditingController();
  final synopsisController = TextEditingController();
  final RxString title = ''.obs;
  final RxString synopsis = ''.obs;
  final RxInt coverIndex = (-1).obs;
  final RxString coverPath = ''.obs;
  final RxBool isPickingCover = false.obs;
  final RxString language = 'English'.obs;
  final RxString audience = ''.obs;
  final RxString rating = ''.obs;
  final RxString novelType = 'Original'.obs;
  final RxString genre = ''.obs;
  final RxList<String> tags = <String>[].obs;
  final RxBool isShort = false.obs;

  // Tag picker sheet state.
  final RxString tagTab = 'Style'.obs;
  final RxSet<String> tagDraft = <String>{}.obs;
  static const maxTags = 10;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments as String?;
    final existing = id == null ? null : _author.story(id);
    isNew = existing == null;
    story = existing ?? _author.newStory();
    titleController.text = title.value = story.title;
    synopsisController.text = synopsis.value = story.synopsis;
    coverIndex.value = story.coverIndex;
    coverPath.value = story.coverPath;
    language.value = story.language;
    audience.value = story.audience;
    rating.value = story.rating;
    novelType.value = story.novelType;
    genre.value = story.genre;
    tags.assignAll(story.tags);
    isShort.value = story.isShort;
  }

  @override
  void onClose() {
    // A photo picked but never saved would otherwise be left on disk.
    if (coverPath.value.isNotEmpty && coverPath.value != story.coverPath) {
      _author.deleteCoverFile(coverPath.value);
    }
    titleController.dispose();
    synopsisController.dispose();
    super.onClose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  int get synopsisWords => AuthorStory.wordCount(synopsis.value);
  bool get synopsisOk =>
      synopsisWords >= AppConstants.synopsisMinWords && synopsisWords <= AppConstants.synopsisMaxWords;

  bool get basicsOk => title.value.trim().isNotEmpty && hasCover && audience.isNotEmpty && rating.isNotEmpty;

  bool get hasCover => coverPath.isNotEmpty || coverIndex.value >= 0;

  bool get detailsOk => genre.isNotEmpty && tags.isNotEmpty && synopsisOk;

  /// Tags grouped by their category, for the chips under "Tags".
  Map<String, List<String>> get tagsByGroup => {
    for (final e in AuthorData.tagGroups.entries)
      if (tags.any(e.value.$2.contains)) e.key: tags.where(e.value.$2.contains).toList(),
  };

  // ── Steps ──────────────────────────────────────────────────────────────────
  void next() {
    if (step.value == 0 && basicsOk) step.value = 1;
  }

  void back() {
    if (step.value > 0) step.value--;
  }

  /// From details: go to review. From review: save.
  void complete() {
    if (step.value == 1 && detailsOk) {
      step.value = 2;
    } else if (step.value == 2) {
      _write();
      Get.back();
      toast(isNew ? 'Story created' : 'Story updated', story.displayTitle);
    }
  }

  /// Saves what's filled in so far; the story shows "Complete the info".
  void skip() {
    _write();
    Get.back();
    toast('Saved', 'Finish your book information before publishing.');
  }

  void _write() {
    if (story.coverPath.isNotEmpty && story.coverPath != coverPath.value) {
      _author.deleteCoverFile(story.coverPath);
    }
    story
      ..title = title.value.trim()
      ..coverIndex = coverIndex.value
      ..coverPath = coverPath.value
      ..language = language.value
      ..audience = audience.value
      ..rating = rating.value
      ..novelType = novelType.value
      ..genre = genre.value
      ..tags = tags.toList()
      ..synopsis = synopsis.value.trim()
      ..isShort = isShort.value;
    _author.saveStory(story);
  }

  // ── Pickers ────────────────────────────────────────────────────────────────
  void pickCover(int index) {
    _discardUnsavedPhoto();
    coverIndex.value = index;
    coverPath.value = '';
    Get.back();
  }

  /// Gallery pick. Downscaled to the 600×800 cover format (×2 for sharp
  /// screens) to keep storage small.
  Future<void> pickFromDevice() async {
    isPickingCover.value = true;
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final path = await _author.importCover(file.path, story.id);
      _discardUnsavedPhoto();
      coverPath.value = path;
    } on PlatformException catch (e) {
      toast('Couldn\'t open your photos', e.message ?? 'Allow photo access in Settings and try again.');
    } finally {
      isPickingCover.value = false;
    }
  }

  void _discardUnsavedPhoto() {
    if (coverPath.value.isNotEmpty && coverPath.value != story.coverPath) {
      _author.deleteCoverFile(coverPath.value);
    }
  }

  void openTagPicker() {
    tagDraft.assignAll(tags);
    tagTab.value = 'Style';
  }

  void toggleTag(String t) {
    if (tagDraft.contains(t)) {
      tagDraft.remove(t);
    } else if (tagDraft.length < maxTags) {
      tagDraft.add(t);
    } else {
      toast('Up to $maxTags tags');
    }
  }

  void confirmTags() {
    tags.assignAll(tagDraft);
    Get.back();
  }

  void removeTag(String t) => tags.remove(t);
}
