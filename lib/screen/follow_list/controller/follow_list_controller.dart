import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/services/account_service.dart';

class FollowListController extends GetxController {
  final _account = Get.find<AccountService>();

  /// 0 = Followers, 1 = Following
  late final int initialTab;

  RxSet<String> get following => _account.following;

  /// Mock accounts don't have followers yet.
  List<String> get followers => const [];

  int storyCount(String author) => MockData.books.where((b) => b.author == author).length;

  @override
  void onInit() {
    super.onInit();
    initialTab = (Get.arguments as int?) ?? 0;
  }

  void toggle(String author) => _account.toggleFollow(author);

  void openAuthor(String author) => Get.toNamed(AppRoutes.authorProfile, arguments: author);
}
