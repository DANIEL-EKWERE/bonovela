import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/wallet_models.dart';
import '../../../core/services/account_service.dart';

class GemsController extends GetxController {
  final _account = Get.find<AccountService>();

  RxInt get gems => _account.gems;
  RxList<GemRecord> get history => _account.gemHistory;

  void goRead() => Get.toNamed(AppRoutes.rewards);
  void goTopUp() => Get.toNamed(AppRoutes.topUp);
}
