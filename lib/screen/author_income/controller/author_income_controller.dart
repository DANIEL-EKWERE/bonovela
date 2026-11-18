import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/api/api_client.dart';
import '../../../core/data/author_data.dart';
import '../../../widgets/ui_kit.dart';

/// Author earnings per month and the balance available to withdraw, from
/// the server (all $0.00 in sample-data builds).
class AuthorIncomeController extends GetxController {
  final Rx<DateTime> month = DateTime(DateTime.now().year, DateTime.now().month).obs;

  /// From GET /api/author/income/?month=…: label → cents, plus totals.
  final RxMap<String, int> amounts = <String, int>{}.obs;
  final RxInt _monthTotal = 0.obs;
  final RxInt _total = 0.obs;

  /// Withdrawal rules from the server: balance, minimum ($100), this month.
  final RxInt available = 0.obs;
  final RxInt minimum = 10000.obs;
  final RxBool canWithdraw = false.obs;
  final RxBool placedThisMonth = false.obs;

  /// Withdrawals placed but not paid yet.
  final RxInt pendingWithdrawal = 0.obs;

  /// Section label → server type key (profit_share…), for the detail page.
  final Map<String, String> _keys = {};

  ApiClient? get _api => Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null;

  @override
  void onInit() {
    super.onInit();
    ever(month, (_) => load());
    load();
  }

  Future<void> load() async {
    final api = _api;
    if (api == null || !api.signedIn) return;
    try {
      final r = await api.get('author/income/', {'month': monthLabel}) as Map;
      final types = (r['types'] as List).cast<Map>();
      for (final t in types) {
        _keys[t['label'].toString()] = t['type'].toString();
      }
      amounts.assignAll({for (final t in types) t['label'].toString(): (t['amount_cents'] as num).toInt()});
      pendingWithdrawal.value = (r['pending_withdrawal_cents'] as num?)?.toInt() ?? 0;
      available.value = (r['available_cents'] as num?)?.toInt() ?? 0;
      final w = r['withdraw'];
      if (w is Map) {
        minimum.value = (w['minimum_cents'] as num?)?.toInt() ?? minimum.value;
        canWithdraw.value = w['can_withdraw'] == true;
        placedThisMonth.value = w['placed_this_month'] == true;
      }
      _monthTotal.value = (r['month_cents'] as num?)?.toInt() ?? 0;
      _total.value = (r['total_cents'] as num?)?.toInt() ?? 0;
    } catch (_) {
      toast("Couldn't load income", 'Pull down to try again.');
    }
  }

  List<(String, int, int)> get types => AuthorData.incomeTypes;

  /// Cents per card for the selected month.
  int amountFor(String type) => amounts[type] ?? 0;

  int get monthTotal => _monthTotal.value;

  int get totalRevenue => _total.value;

  static String money(int cents) => '\$${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

  String get monthLabel => '${month.value.year}-${month.value.month.toString().padLeft(2, '0')}';

  void prevMonth() => month.value = DateTime(month.value.year, month.value.month - 1);

  void nextMonth() {
    final now = DateTime.now();
    final next = DateTime(month.value.year, month.value.month + 1);
    if (!next.isAfter(DateTime(now.year, now.month))) month.value = next;
  }

  void paymentInfo() => Get.toNamed(AppRoutes.paymentInfo);

  /// Available to withdraw: open the withdrawal page.
  void withdraw() => Get.toNamed(AppRoutes.paymentInfo, arguments: {'withdraw': true})?.then((_) => load());

  void history() => Get.toNamed(AppRoutes.withdrawals);

  String get withdrawNote =>
      (pendingWithdrawal.value > 0 ? 'Pending withdrawal: ${money(pendingWithdrawal.value)} · ' : '') + _withdrawNote;

  String get _withdrawNote => canWithdraw.value
      ? 'Withdraw now ›'
      : placedThisMonth.value
      ? "This month's withdrawal is placed"
      : 'Withdraw from ${money(minimum.value)}';

  /// Tap a section: the books that earned it this month (Carry over explains itself).
  void openType(String type) {
    if (type == 'Carry over') {
      return toast(
        'Carry over',
        'Unwithdrawn earnings from earlier months. Finance moves it to Available to withdraw.',
      );
    }
    final key = _keys[type];
    if (key == null) return toast(type, 'No income from $type in $monthLabel yet.');
    Get.toNamed(AppRoutes.incomeDetail, arguments: {'type': key, 'label': type, 'month': monthLabel});
  }

  void help() => toast(
    'How income works',
    'Signed stories earn a profit share on every unlocked chapter. Available to withdraw is what you can be paid now.',
  );
}
