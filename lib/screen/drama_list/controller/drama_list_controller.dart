import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/drama_model.dart';

/// "More" page for a Drama section.
class DramaListController extends GetxController {
  late final String title;
  late final List<DramaModel> dramas;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    title = args['title']?.toString() ?? 'Drama';
    dramas = (args['dramas'] as List?)?.cast<DramaModel>() ?? const [];
  }

  void play(DramaModel d) => Get.toNamed(AppRoutes.dramaPlayer, arguments: {'dramaId': d.id});
}
