import 'package:get/get.dart';

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

  /// Credits the package through the backend (sample-data builds: on the phone).
  Future<void> pay() async {
    isPaying.value = true;
    final p = selected.value;
    final error = await _account.buyCoins(coinAmount: p.coins, bonusAmount: p.bonus, price: p.price);
    isPaying.value = false;
    Get.back(); // payment sheet
    if (error != null) return toast("Top up didn't go through", error);
    toast('Top up successful', '+${p.coins} coins${p.bonus > 0 ? ' · +${p.bonus} bonus' : ''} · +3 vouchers');
  }
}
