import 'package:get/get.dart';

import '../controller/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletController());
  }
}
