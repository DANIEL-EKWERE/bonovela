import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/api/api_client.dart';
import '../../../widgets/ui_kit.dart';

/// Where the author's earnings are paid, and the withdrawal page (opened
/// with arguments {'withdraw': true}). Same fields and rules as the web
/// dashboard: PUT /api/author/payout-method/, POST /api/author/withdrawals/.
class PaymentInfoController extends GetxController {
  /// Withdrawal page: the amount, then the account it goes to.
  final bool withdrawMode = (Get.arguments is Map) && (Get.arguments as Map)['withdraw'] == true;
  final amount = TextEditingController();
  final RxInt available = 0.obs;
  final RxInt minimum = 10000.obs;
  final RxInt maximum = 1000000.obs;
  final RxBool canWithdraw = false.obs;
  final RxBool placedThisMonth = false.obs;

  /// "YES, I am aware" pressed in the check dialog: Place withdrawal shows.
  final RxBool aware = false.obs;

  static const bankFields = [
    'country',
    'currency',
    'bank_name',
    'swift_code',
    'address',
    'city',
    'state',
    'postal_code',
  ];

  final RxString method = 'bank'.obs;
  final RxString currency = 'USD'.obs;
  final fields = <String, TextEditingController>{
    for (final k in [
      'country',
      'bank_name',
      'swift_code',
      'account_detail',
      'account_name',
      'intermediary_swift',
      'nickname',
      'email',
      'address',
      'city',
      'state',
      'postal_code',
    ])
      k: TextEditingController(),
  };
  final RxMap<String, String> errors = <String, String>{}.obs;
  final RxBool loading = true.obs;
  final RxBool saving = false.obs;

  ApiClient? get _api => Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  void onClose() {
    for (final c in fields.values) {
      c.dispose();
    }
    amount.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    try {
      final r = await _api?.get('author/payout-method/');
      if (r is Map) {
        method.value = r['method']?.toString() ?? 'bank';
        currency.value = (r['currency']?.toString() ?? '').isEmpty ? 'USD' : r['currency'].toString();
        for (final e in fields.entries) {
          e.value.text = r[e.key]?.toString() ?? '';
        }
      }
      if (withdrawMode) {
        final w = await _api?.get('author/withdrawals/');
        final rules = w is Map ? w['rules'] : null;
        if (rules is Map) {
          available.value = (rules['available_cents'] as num?)?.toInt() ?? 0;
          minimum.value = (rules['minimum_cents'] as num?)?.toInt() ?? minimum.value;
          maximum.value = (rules['maximum_cents'] as num?)?.toInt() ?? maximum.value;
          canWithdraw.value = rules['can_withdraw'] == true;
          placedThisMonth.value = rules['placed_this_month'] == true;
          amount.text = (available.value / 100).toStringAsFixed(2);
        }
      }
    } catch (_) {
    } finally {
      loading.value = false;
    }
  }

  static String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  int get amountCents => ((double.tryParse(amount.text.trim()) ?? 0) * 100).round();

  bool get isBank => method.value == 'bank';

  String v(String k) => fields[k]!.text.trim();

  /// Checked here first; the server checks again.
  bool _valid() {
    final e = <String, String>{};
    for (final k in ['account_detail', 'account_name', if (isBank) ...bankFields.where((f) => f != 'currency')]) {
      if (v(k).isEmpty) e[k] = isBank && bankFields.contains(k) ? 'Required for bank transfers.' : 'Required.';
    }
    if (RegExp(r'^(P\.?O\.?|GPO) BOX', caseSensitive: false).hasMatch(v('address'))) {
      e['address'] = 'Use a street address, not a PO or GPO box.';
    }
    if (withdrawMode) {
      final c = amountCents;
      if (c < minimum.value) {
        e['amount'] = 'Amount must be at least ${money(minimum.value)}.';
      } else if (c > available.value) {
        e['amount'] = 'More than your available balance (${money(available.value)}).';
      } else if (c > maximum.value) {
        e['amount'] = 'The most you can withdraw at once is ${money(maximum.value)}.';
      }
    }
    errors.assignAll(e);
    return e.isEmpty;
  }

  /// Submit → "Please Check Your Information" → YES, I am aware → Place
  /// withdrawal (or Save on Payment Info).
  void submit() {
    if (!_valid()) return toast('Please check the highlighted fields');
    final rows = [
      if (withdrawMode) ('Withdraw Amount', money(amountCents)),
      ('Payment Method', isBank ? 'Bank' : 'PayPal'),
      ('Full Name of Account Holder', v('account_name')),
      (isBank ? 'Account Number / IBAN' : 'PayPal email', v('account_detail')),
      if (isBank) ...[
        ("Beneficiary's Bank", v('bank_name')),
        ('SWIFT code / BIC', v('swift_code')),
        ('Bank Branch / Address', '${v('address')}, ${v('city')}, ${v('state')} ${v('postal_code')}'),
        ('Country', v('country')),
        ('Currency', currency.value),
      ],
    ];
    aware.value = false;
    Get.dialog(
      AlertDialog(
        title: const Text('Please Check Your Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'We will send your payment to the account you provided. Please make sure all information is correct '
                'before submitting. If the transfer fails because of incorrect information, your request will be '
                'denied and you will need to request again next month.',
                style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 12),
              for (final (k, value) in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(k, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Close')),
          Obx(
            () => aware.value
                ? FilledButton(
                    onPressed: () {
                      Get.back();
                      _save();
                    },
                    child: Text(withdrawMode ? 'Place withdrawal' : 'Save payment info'),
                  )
                : FilledButton(onPressed: () => aware.value = true, child: const Text('YES, I am aware')),
          ),
        ],
      ),
    );
  }

  /// Leaves the withdrawal page for Payment Info (a fresh page, not in
  /// withdraw mode).
  void manageAccounts() => Get.offNamed(AppRoutes.paymentInfo);

  Future<void> _save() async {
    final api = _api;
    if (api == null) return toast('Payment info saved');
    saving.value = true;
    final body = {
      'method': method.value,
      'currency': isBank ? currency.value : '',
      for (final e in fields.entries) e.key: e.value.text.trim(),
      'confirmed': true,
    };
    try {
      if (withdrawMode) {
        await api.post('author/withdrawals/', {...body, 'amount_cents': amountCents});
        Get.back();
        toast('Withdrawal placed', 'It is processed on the 11th of next month.');
        return;
      }
      await api.put('author/payout-method/', body);
      Get.back();
      toast('Payment info saved');
    } on ApiException catch (e) {
      errors.assignAll({for (final f in e.fields.entries) f.key: f.value.first});
      if (e.code == 'withdrawal') errors['amount'] = e.message;
      toast(withdrawMode ? "Couldn't place the withdrawal" : "Couldn't save yet", e.message);
    } catch (_) {
      toast("Couldn't reach Bonovela", 'Check your connection and try again.');
    } finally {
      saving.value = false;
    }
  }
}
