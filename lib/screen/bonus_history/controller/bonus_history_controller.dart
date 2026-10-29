import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/wallet_models.dart';
import '../../../core/services/account_service.dart';

class BonusHistoryController extends GetxController {
  final _account = Get.find<AccountService>();

  RxInt get balance => _account.bonus;
  RxList<BonusRecord> get records => _account.bonusRecords;

  /// Expanded record ids.
  final RxSet<String> expanded = <String>{}.obs;

  void toggle(String id) => expanded.contains(id) ? expanded.remove(id) : expanded.add(id);

  void getMore() => Get.toNamed(AppRoutes.rewards);
}
