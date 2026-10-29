import 'package:get/get.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/models/book_model.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

class AuthorProfileController extends GetxController {
  final _account = Get.find<AccountService>();

  final String author;

  AuthorProfileController(this.author);

  late final List<BookModel> books = MockData.booksBy(author);
  late final int baseFollowers = MockData.followersOf(author);
  late final String bio = MockData.bioOf(author);

  bool get isFollowing => _account.following.contains(author);
  int get followers => baseFollowers + (isFollowing ? 1 : 0);

  void toggleFollow() => _account.toggleFollow(author);

  void report() => toast('Report sent', 'Thanks, our team will review $author\'s profile.');

  void block() {
    if (isFollowing) _account.toggleFollow(author);
    Get.back();
    toast('$author blocked', 'You won\'t see notifications from this author.');
  }
}
