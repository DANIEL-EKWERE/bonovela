import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/author_models.dart';
import '../../../core/services/author_service.dart';
import '../../../widgets/ui_kit.dart';

class AuthorCommentsController extends GetxController {
  final _author = Get.find<AuthorService>();

  /// null = all books.
  final RxnString storyFilter = RxnString();

  /// 0 = all ratings, otherwise exact stars.
  final RxInt starFilter = 0.obs;

  final replyController = TextEditingController();

  @override
  void onClose() {
    replyController.dispose();
    super.onClose();
  }

  RxList<AuthorStory> get stories => _author.stories;

  String storyTitle(String id) => _author.story(id)?.displayTitle ?? '';

  List<AuthorComment> get comments {
    _author.chapters.length;
    _author.replies.length;
    final list =
        [
            for (final s in _author.stories)
              if (storyFilter.value == null || storyFilter.value == s.id) ..._author.commentsFor(s),
          ].where((c) => starFilter.value == 0 || c.stars == starFilter.value).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void reply(AuthorComment c) {
    final text = replyController.text.trim();
    if (text.isEmpty) return;
    _author.reply(c.id, text);
    replyController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    toast('Reply sent');
  }

  List<String> repliesOf(AuthorComment c) => _author.replies[c.id] ?? [];
}
