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
      amounts.assignAll({
        for (final t in (r['types'] as List).cast<Map>()) t['label'].toString(): (t['amount_cents'] as num).toInt(),
        'Available to withdraw': (r['available_cents'] as num?)?.toInt() ?? 0,
      });
      _monthTotal.value = (r['month_cents'] as num?)?.toInt() ?? 0;
      _total.value = (r['total_cents'] as num?)?.toInt() ?? 0;
    } catch (_) {
      toast("Couldn't load income", 'Pull down to try again.');
    }
  }

  List<(String, int, int)> get types => AuthorData.incomeTypes;

  /// Cents per card for the selected month (Available to withdraw is all-time).
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

  void openType(String type) => toast(type, 'No income from $type in $monthLabel yet.');

  void help() => toast(
    'How income works',
    'Signed stories earn a profit share on every unlocked chapter. Available to withdraw is what you can be paid now.',
  );
}
