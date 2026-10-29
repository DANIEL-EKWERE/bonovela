import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/services/account_service.dart';

class WalletController extends GetxController {
  final _account = Get.find<AccountService>();

  RxInt get coins => _account.coins;
  RxInt get bonus => _account.bonus;

  void topUp() => Get.toNamed(AppRoutes.topUp);
  void open(String route) => Get.toNamed(route);
}
