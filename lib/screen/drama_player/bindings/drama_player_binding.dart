import 'package:get/get.dart';

import '../controller/drama_player_controller.dart';

class DramaPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DramaPlayerController());
  }
}
