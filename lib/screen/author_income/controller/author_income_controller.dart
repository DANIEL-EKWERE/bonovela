import 'package:get/get.dart';

import '../../../core/data/author_data.dart';
import '../../../widgets/ui_kit.dart';

/// Author earnings. Everything is $0.00 until stories are signed; the mock
/// only carries over a few cents to show the card states.
class AuthorIncomeController extends GetxController {
  final Rx<DateTime> month = DateTime(DateTime.now().year, DateTime.now().month).obs;

  List<(String, int, int)> get types => AuthorData.incomeTypes;

  /// Cents per category for the selected month.
  int amountFor(String type) => type == 'Carry over' ? 5 : 0;

  int get monthTotal => types.fold(0, (s, t) => s + amountFor(t.$1));

  int get totalRevenue => monthTotal;

  static String money(int cents) => '\$${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

  String get monthLabel => '${month.value.year}-${month.value.month.toString().padLeft(2, '0')}';

  void prevMonth() => month.value = DateTime(month.value.year, month.value.month - 1);

  void nextMonth() {
    final now = DateTime.now();
    final next = DateTime(month.value.year, month.value.month + 1);
    if (!next.isAfter(DateTime(now.year, now.month))) month.value = next;
  }

  void paymentInfo() => toast('Payment info', 'Add a bank account or PayPal once your first story is signed.');

  void openType(String type) => toast(type, 'No income from $type in $monthLabel yet.');

  void help() => toast(
    'How income works',
    'Signed stories earn a profit share on every unlocked chapter, plus attendance and completion bonuses.',
  );
}
