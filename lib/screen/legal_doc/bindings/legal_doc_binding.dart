import 'package:get/get.dart';

import '../controller/legal_doc_controller.dart';

class LegalDocBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LegalDocController());
  }
}
