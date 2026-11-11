import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/api/api_client.dart';
import '../../../widgets/ui_kit.dart';

/// Where the author's earnings are paid. Same fields and rules as the web
/// dashboard's Payment Info (PUT /api/author/payout-method/).
class PaymentInfoController extends GetxController {
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
    } catch (_) {
    } finally {
      loading.value = false;
    }
  }

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
    errors.assignAll(e);
    return e.isEmpty;
  }

  /// Submit → "Please Check Your Information" → YES, I am aware → save.
  void submit() {
    if (!_valid()) return toast('Please check the highlighted fields');
    final rows = [
      ('Payment Method', isBank ? 'Bank' : 'PayPal'),
      ('Full Name of Account Holder', v('account_name')),
      (isBank ? 'Account Number' : 'PayPal email', v('account_detail')),
      if (isBank) ...[
        ("Beneficiary's Bank", v('bank_name')),
        ('SWIFT code / BIC', v('swift_code')),
        ('Country', v('country')),
        ('Currency', currency.value),
        ('Address', '${v('address')}, ${v('city')}, ${v('state')} ${v('postal_code')}'),
      ],
    ];
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
                'before submitting. If a transfer fails because of incorrect details, it will be delayed until the '
                'next payment cycle.',
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
          FilledButton(
            onPressed: () {
              Get.back();
              _save();
            },
            child: const Text('YES, I am aware'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final api = _api;
    if (api == null) return toast('Payment info saved');
    saving.value = true;
    try {
      await api.put('author/payout-method/', {
        'method': method.value,
        'currency': isBank ? currency.value : '',
        for (final e in fields.entries) e.key: e.value.text.trim(),
        'confirmed': true,
      });
      Get.back();
      toast('Payment info saved');
    } on ApiException catch (e) {
      errors.assignAll({for (final f in e.fields.entries) f.key: f.value.first});
      toast("Couldn't save yet", e.message);
    } catch (_) {
      toast("Couldn't reach Bonovela", 'Check your connection and try again.');
    } finally {
      saving.value = false;
    }
  }
}
