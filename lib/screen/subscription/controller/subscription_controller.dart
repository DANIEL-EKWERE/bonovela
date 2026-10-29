import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';
import '../models/plan.dart';

class SubscriptionController extends GetxController {
  final _account = Get.find<AccountService>();

  final plans = SubscriptionPlan.all;
  final Rx<SubscriptionPlan> selected = SubscriptionPlan.all[1].obs;
  final RxBool isPaying = false.obs;

  Rxn<UserModel> get user => _account.user;
  Rxn<DateTime> get plusUntil => _account.plusUntil;
  bool get isPlus => _account.isPlus;

  Future<void> subscribe() async {
    if (!_account.isLoggedIn) {
      Get.toNamed(AppRoutes.login);
      return;
    }
    isPaying.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    final p = selected.value;
    _account.subscribe(plan: p.name, price: p.price, days: p.days);
    isPaying.value = false;
    toast('Welcome to Bonovela Plus 💗', 'All short stories are now unlimited.');
  }

  void restore() => toast('Restore purchases', isPlus ? 'Your subscription is active.' : 'No previous purchases found.');
}
