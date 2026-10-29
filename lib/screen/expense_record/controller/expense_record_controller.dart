import 'package:get/get.dart';

import '../../../core/models/wallet_models.dart';
import '../../../core/services/account_service.dart';

class ExpenseRecordController extends GetxController {
  final _account = Get.find<AccountService>();

  /// Spending in the last 30 days.
  List<WalletTransaction> get items {
    final since = DateTime.now().subtract(const Duration(days: 30));
    return _account.transactions.where((t) => t.isExpense && t.date.isAfter(since)).toList();
  }
}
