import 'package:get/get.dart';

import '../../../config/routes.dart';

class TermsPolicyController extends GetxController {
  final docs = const ['Terms of Use', 'Privacy Policy', 'DMCA', 'Content Guidelines'];

  void open(String doc) => Get.toNamed(AppRoutes.legalDoc, arguments: doc);
}
