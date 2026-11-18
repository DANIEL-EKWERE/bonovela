import 'package:get/get.dart';

import '../../../core/api/api_client.dart';

/// One Income section in a month: each book that earned it and how much.
class IncomeDetailController extends GetxController {
  final Map args = (Get.arguments as Map?) ?? const {};
  final RxList<Map> books = <Map>[].obs;
  final RxList<Map> others = <Map>[].obs;
  final RxInt total = 0.obs;
  final RxBool loading = true.obs;

  String get label => args['label']?.toString() ?? 'Income';
  String get month => args['month']?.toString() ?? '';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      final api = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null;
      final r = await api?.get('author/income/${args['type']}/', {'month': month});
      if (r is Map) {
        books.assignAll((r['books'] as List).cast<Map>());
        others.assignAll((r['others'] as List).cast<Map>());
        total.value = (r['total_cents'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {
    } finally {
      loading.value = false;
    }
  }

  static String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
}
