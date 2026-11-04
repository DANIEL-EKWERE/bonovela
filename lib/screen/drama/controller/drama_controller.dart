import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/drama_model.dart';
import '../../../core/services/drama_service.dart';

/// Drama tab: Popular Picks → New Release → You May Also Like → Trending.
class DramaController extends GetxController {
  final service = Get.find<DramaService>();

  late final List<DramaModel> popular;
  late final List<DramaModel> newRelease;
  late final List<DramaModel> youMayLike;
  late final List<DramaModel> trending;

  /// Highlighted card in "You May Also Like".
  final RxInt likeIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final all = service.dramas;
    popular = ([...all]..sort((a, b) => b.plays.compareTo(a.plays))).take(6).toList();
    newRelease = ([...all]..sort((a, b) => b.releasedAt.compareTo(a.releasedAt))).take(9).toList();
    final shown = {...popular, ...newRelease}.map((d) => d.id).toSet();
    youMayLike = [...all.where((d) => !shown.contains(d.id)), ...popular.reversed].take(8).toList();
    trending = ([...all]..sort((a, b) => (b.plays ~/ (b.episodeCount)).compareTo(a.plays ~/ a.episodeCount)))
        .take(9)
        .toList();
  }

  DramaModel get liked => youMayLike[likeIndex.value];

  void play(DramaModel d) => Get.toNamed(AppRoutes.dramaPlayer, arguments: {'dramaId': d.id});

  void viewAll(String title, List<DramaModel> list) =>
      Get.toNamed(AppRoutes.dramaList, arguments: {'title': title, 'dramas': list});
}
