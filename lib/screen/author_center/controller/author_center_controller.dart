import 'package:get/get.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

/// Author Center shell: intro for readers, five-tab dashboard for authors.
class AuthorCenterController extends GetxController {
  final _account = Get.find<AccountService>();

  /// 0 Stories · 1 Discover · 2 Calendar · 3 Comments · 4 Income
  final RxInt tab = 0.obs;

  Rxn<UserModel> get user => _account.user;
  bool get isAuthor => _account.user.value?.isAuthor ?? false;

  void changeTab(int i) => tab.value = i;

  Future<void> becomeAuthor() async {
    try {
      await _account.becomeAuthor();
      toast('Welcome, author ✍️', 'Tap + to start your first story.');
    } catch (_) {
      toast("Couldn't reach Bonovela", 'Check your connection and try again.');
    }
  }
}
