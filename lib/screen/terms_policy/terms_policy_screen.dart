import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/ui_kit.dart';
import 'controller/terms_policy_controller.dart';

class TermsPolicyScreen extends GetView<TermsPolicyController> {
  const TermsPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Terms and Policy',
      background: Colors.white,
      body: ListView(
        children: [for (final d in controller.docs) MenuTile(title: d, onTap: () => controller.open(d))],
      ),
    );
  }
}
