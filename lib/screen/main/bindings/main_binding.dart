import 'package:get/get.dart';

import '../../discover/bindings/discover_binding.dart';
import '../../library/bindings/library_binding.dart';
import '../../profile/bindings/profile_binding.dart';
import '../../rank/bindings/rank_binding.dart';
import '../../short/bindings/short_binding.dart';
import '../controller/main_controller.dart';

/// Registers the shell controller plus each tab's own binding. Tab
/// controllers are lazy, so a tab loads its data the first time it is shown.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainController());
    LibraryBinding().dependencies();
    DiscoverBinding().dependencies();
    ShortBinding().dependencies();
    RankBinding().dependencies();
    ProfileBinding().dependencies();
  }
}
