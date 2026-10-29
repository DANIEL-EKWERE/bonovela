import 'package:get/get.dart';

import '../../../core/models/wallet_models.dart';
import '../../../core/services/account_service.dart';

class TransactionHistoryController extends GetxController {
  final _account = Get.find<AccountService>();

  /// Purchases and coin grants — everything that added coins.
  List<WalletTransaction> get items =>
      _account.transactions.where((t) => !t.isExpense).toList();
}
