import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/drama_model.dart';
import '../../../core/services/account_service.dart';
import '../../../core/services/drama_service.dart';
import '../../../widgets/ui_kit.dart';

/// Vertical episode player. Swipe up for the next episode. Playback is
/// simulated with a timer until episodes have real video URLs.
class DramaPlayerController extends GetxController {
  final service = Get.find<DramaService>();
  final account = Get.find<AccountService>();

  late final DramaModel drama;
  late final PageController pages;

  final RxInt episode = 1.obs;
  final RxBool playing = false.obs;
  final RxDouble position = 0.0.obs; // seconds
  final RxBool showControls = true.obs;

  Timer? _ticker;
  static const _tick = Duration(milliseconds: 250);

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    drama = service.byId(args['dramaId'].toString()) ?? service.dramas.first;
    final start = (args['episode'] as int?) ?? service.lastEpisode(drama.id);
    episode.value = start.clamp(1, drama.episodeCount);
    pages = PageController(initialPage: episode.value - 1);
    _start();
  }

  int get duration => drama.episodeSeconds(episode.value);
  bool get canWatch => service.canWatch(drama, episode.value);
  double get progress => duration == 0 ? 0 : (position.value / duration).clamp(0, 1);

  void onPageChanged(int index) {
    episode.value = index + 1;
    position.value = 0;
    _start();
  }

  void _start() {
    service.recordWatch(drama.id, episode.value);
    canWatch ? play() : pause();
  }

  void play() {
    if (!canWatch) return;
    playing.value = true;
    _ticker?.cancel();
    _ticker = Timer.periodic(_tick, (_) {
      position.value += _tick.inMilliseconds / 1000;
      if (position.value >= duration) _finished();
    });
  }

  void pause() {
    playing.value = false;
    _ticker?.cancel();
  }

  void togglePlay() {
    if (!canWatch) return;
    playing.value ? pause() : play();
    showControls.value = true;
  }

  void seek(double fraction) => position.value = duration * fraction.clamp(0, 1);

  void _finished() {
    pause();
    position.value = duration.toDouble();
    if (episode.value < drama.episodeCount) {
      pages.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      toast('That\'s the finale', 'You\'ve watched every episode of ${drama.title}.');
    }
  }

  void jumpTo(int ep) {
    Get.back();
    pages.jumpToPage(ep - 1);
  }

  void unlock() {
    if (service.unlock(drama, episode.value)) {
      toast('Episode ${episode.value} unlocked');
      episode.refresh();
      play();
    } else {
      toast('Not enough coins', 'Top up to keep watching.');
      Get.toNamed(AppRoutes.topUp);
    }
  }

  void getPlus() => Get.toNamed(AppRoutes.subscription);

  void readNovel() {
    if (drama.bookId == null) return;
    pause();
    Get.toNamed(AppRoutes.bookDetail, arguments: drama.bookId);
  }

  String get priceLabel => '${AppConstants.episodePrice} coins';

  @override
  void onClose() {
    _ticker?.cancel();
    pages.dispose();
    super.onClose();
  }
}
