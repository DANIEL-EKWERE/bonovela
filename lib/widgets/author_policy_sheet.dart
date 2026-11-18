import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/api/api_client.dart';
import '../core/constants/app_colors.dart';
import 'common.dart';

/// Before an author account is created: the Bonovela Author Policy (reading
/// it is optional) and an "I agree" checkbox. Resolves true when they agree.
Future<bool> showAuthorPolicySheet() async {
  final agreed = await Get.bottomSheet<bool>(
    const _PolicySheet(),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
  );
  return agreed ?? false;
}

class _PolicySheet extends StatefulWidget {
  const _PolicySheet();

  @override
  State<_PolicySheet> createState() => _PolicySheetState();
}

class _PolicySheetState extends State<_PolicySheet> {
  bool agree = false;
  List<Map> blocks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null;
      final r = await api?.get('author-policy/');
      if (r is Map) blocks = (r['blocks'] as List).cast<Map>();
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  Widget _block(Map b) {
    final text = b['text']?.toString() ?? '';
    return switch (b['type']) {
      'h1' => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      'h2' => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ),
      'h3' => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 4),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
      'li' => Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 4),
        child: Text('•  $text', style: const TextStyle(fontSize: 13, height: 1.4)),
      ),
      _ => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 13, height: 1.45)),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bonovela Author Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text(
                'Please read our policy before creating your author account. Reading it is optional.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    title: const Text('Tap to read the policy', style: TextStyle(fontWeight: FontWeight.w600)),
                    shape: const Border(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.45,
                        child: loading
                            ? const Center(child: CircularProgressIndicator())
                            : blocks.isEmpty
                            ? const Center(child: Text("Couldn't load the policy. You can read it on bonovela.com."))
                            : ListView(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                children: [for (final b in blocks) _block(b)],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              CheckboxListTile(
                value: agree,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('I have read and agree to the Bonovela Author Policy'),
                onChanged: (v) => setState(() => agree = v ?? false),
              ),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: 'I agree — create my author account',
                  onTap: agree ? () => Get.back(result: true) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
