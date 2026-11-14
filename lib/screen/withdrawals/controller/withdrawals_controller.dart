import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/api/api_client.dart';

/// One withdrawal or payment, as the author sees it.
class WithdrawalRecord {
  final String code;
  final String category;
  final int requestedCents;
  final int? approvedCents;

  /// Pending | Processing | Successful | Failed — returned to balance.
  final String status;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String reference;
  final String paidTo;

  const WithdrawalRecord({
    required this.code,
    required this.category,
    required this.requestedCents,
    required this.approvedCents,
    required this.status,
    required this.createdAt,
    required this.paidAt,
    required this.reference,
    required this.paidTo,
  });

  factory WithdrawalRecord.fromJson(Map j) => WithdrawalRecord(
    code: j['code']?.toString() ?? '',
    category: j['category']?.toString() ?? 'Withdrawal',
    requestedCents: (j['requested_cents'] as num?)?.toInt() ?? 0,
    approvedCents: (j['approved_cents'] as num?)?.toInt(),
    status: j['status']?.toString() ?? 'Pending',
    createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ?? DateTime.now(),
    paidAt: DateTime.tryParse(j['paid_at']?.toString() ?? ''),
    reference: j['reference']?.toString() ?? '',
    paidTo: j['paid_to']?.toString() ?? '',
  );
}

/// Withdrawal history (GET /api/author/withdrawals/).
class WithdrawalsController extends GetxController {
  final RxList<WithdrawalRecord> rows = <WithdrawalRecord>[].obs;
  final RxBool loading = true.obs;
  final RxBool failed = false.obs;

  ApiClient? get _api => Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final api = _api;
    failed.value = false;
    if (api == null || !api.signedIn) {
      loading.value = false;
      return;
    }
    try {
      final r = await api.get('author/withdrawals/') as Map;
      rows.assignAll([for (final w in (r['withdrawals'] as List).cast<Map>()) WithdrawalRecord.fromJson(w)]);
    } catch (_) {
      failed.value = true;
    } finally {
      loading.value = false;
    }
  }

  void withdraw() => Get.toNamed(AppRoutes.paymentInfo, arguments: {'withdraw': true})?.then((_) => load());
}
