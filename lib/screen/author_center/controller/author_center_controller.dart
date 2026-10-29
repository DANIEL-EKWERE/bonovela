import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/local_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';
import '../models/story_draft.dart';

class AuthorCenterController extends GetxController {
  final _account = Get.find<AccountService>();
  final _storage = Get.find<LocalStorage>();

  static const _kDrafts = 'author_drafts';

  final RxList<StoryDraft> drafts = <StoryDraft>[].obs;

  final titleController = TextEditingController();
  final synopsisController = TextEditingController();
  final RxString genre = AppConstants.genres.first.obs;

  Rxn<UserModel> get user => _account.user;
  bool get isAuthor => _account.user.value?.isAuthor ?? false;

  @override
  void onInit() {
    super.onInit();
    drafts.assignAll((_storage.read<List>(_kDrafts) ?? []).whereType<Map>().map(StoryDraft.fromJson));
  }

  @override
  void onClose() {
    titleController.dispose();
    synopsisController.dispose();
    super.onClose();
  }

  void becomeAuthor() {
    _account.becomeAuthor();
    toast('Welcome, author ✍️', 'Start your first story below.');
  }

  bool createStory() {
    final title = titleController.text.trim();
    final synopsis = synopsisController.text.trim();
    if (title.isEmpty) {
      toast('Give your story a title');
      return false;
    }
    drafts.insert(
      0,
      StoryDraft(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        genre: genre.value,
        synopsis: synopsis,
        updatedAt: DateTime.now(),
      ),
    );
    _save();
    titleController.clear();
    synopsisController.clear();
    toast('Draft saved', title);
    return true;
  }

  void deleteDraft(StoryDraft d) {
    drafts.remove(d);
    _save();
  }

  void _save() => _storage.write(_kDrafts, drafts.map((d) => d.toJson()).toList());
}
