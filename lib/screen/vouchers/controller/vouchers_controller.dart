import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/wallet_models.dart';
import '../../../core/services/account_service.dart';

class VouchersController extends GetxController {
  final _account = Get.find<AccountService>();

  RxInt get vouchers => _account.vouchers;
  RxList<VoucherRecord> get history => _account.voucherHistory;

  void goRead() => Get.toNamed(AppRoutes.rewards);
  void goTopUp() => Get.toNamed(AppRoutes.topUp);
}
