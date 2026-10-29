import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/account_service.dart';
import '../../library/controller/library_controller.dart';
import '../../main/controller/main_controller.dart';

class ProfileController extends GetxController {
  final _account = Get.find<AccountService>();

  Rxn<UserModel> get user => _account.user;
  RxInt get coins => _account.coins;
  RxInt get bonus => _account.bonus;
  RxInt get gems => _account.gems;
  RxSet<String> get following => _account.following;
  bool get isPlus => _account.isPlus;
  int get unread => _account.unreadCount;

  void open(String route, {dynamic arguments}) => Get.toNamed(route, arguments: arguments);

  /// Signed-out users go to login first for account-only screens.
  void openAuthed(String route, {dynamic arguments}) =>
      Get.toNamed(_account.isLoggedIn ? route : AppRoutes.login, arguments: arguments);

  void openHeader() => openAuthed(AppRoutes.editProfile);

  /// "Viewed" jumps to the Library tab's history.
  void openViewed() {
    Get.find<LibraryController>().tabIndex.value = 1;
    Get.find<MainController>().changeTab(0);
  }
}
