import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';
import '../models/coin_package.dart';

class TopUpController extends GetxController {
  final _account = Get.find<AccountService>();

  final packages = CoinPackage.all;
  final Rx<CoinPackage> selected = CoinPackage.all[2].obs;
  final RxString method = 'Card'.obs;
  final RxBool isPaying = false.obs;

  final methods = const ['Card', 'Bank transfer', 'USSD'];

  RxInt get coins => _account.coins;
  RxInt get bonus => _account.bonus;

  /// Simulated checkout — no money moves.
  Future<void> pay() async {
    isPaying.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    final p = selected.value;
    _account.topUp(coinAmount: p.coins, bonusAmount: p.bonus, price: p.price);
    isPaying.value = false;
    Get.back(); // payment sheet
    toast('Top up successful', '+${p.coins} coins${p.bonus > 0 ? ' · +${p.bonus} bonus' : ''} · +3 gems');
  }

  void openSubscription() => Get.toNamed(AppRoutes.subscription);
}
