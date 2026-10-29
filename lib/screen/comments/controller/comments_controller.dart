import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/comment_model.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

class CommentsController extends GetxController {
  final _account = Get.find<AccountService>();

  late final BookModel book;
  final textController = TextEditingController();
  final RxInt stars = 5.obs;
  final RxSet<String> liked = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    book = MockData.books.firstWhere((b) => b.id == Get.arguments as String);
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  /// Your reviews first, then the sample ones.
  List<CommentModel> get comments => [
        ..._account.myComments.where((c) => c.bookId == book.id),
        ...MockData.commentsFor(book),
      ];

  double get average {
    final list = comments;
    return list.isEmpty ? 0 : list.fold(0, (s, c) => s + c.stars) / list.length;
  }

  void toggleLike(CommentModel c) => liked.contains(c.id) ? liked.remove(c.id) : liked.add(c.id);

  void post() {
    final user = _account.user.value;
    if (user == null) {
      Get.toNamed(AppRoutes.login);
      return;
    }
    final text = textController.text.trim();
    if (text.isEmpty) return toast('Write something first');
    _account.addComment(CommentModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      bookId: book.id,
      userName: user.name,
      stars: stars.value,
      text: text,
      date: DateTime.now(),
      isMine: true,
    ));
    textController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    toast('Review posted');
  }
}
