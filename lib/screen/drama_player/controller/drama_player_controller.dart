import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../config/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/drama_model.dart';
import '../../../core/services/account_service.dart';
import '../../../core/services/drama_service.dart';
import '../../../widgets/ui_kit.dart';

/// Vertical episode player. Swipe up for the next episode. Plays the
/// episode's video from the server; without one (sample data, or an episode
/// still processing) playback is simulated with a timer over the poster.
class DramaPlayerController extends GetxController {
  final service = Get.find<DramaService>();
  final account = Get.find<AccountService>();

  late final DramaModel drama;
  late final PageController pages;

  final RxInt episode = 1.obs;
  final RxBool playing = false.obs;
  final RxDouble position = 0.0.obs; // seconds
  final RxBool showControls = true.obs;
  final RxBool unlocking = false.obs;

  /// The current episode's video, when it has one.
  final Rxn<VideoPlayerController> video = Rxn<VideoPlayerController>();

  Timer? _ticker;
  static const _tick = Duration(milliseconds: 250);

  /// Ignores late answers for an episode the viewer already swiped past.
  int _loadToken = 0;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    drama = service.byId(args['dramaId'].toString()) ?? service.dramas.first;
    final start = (args['episode'] as int?) ?? service.lastEpisode(drama.id);
    episode.value = start.clamp(1, drama.episodeCount < 1 ? 1 : drama.episodeCount);
    pages = PageController(initialPage: episode.value - 1);
    service.loadEpisodes(drama).then((_) => _start());
  }

  int get duration {
    final v = video.value;
    if (v != null && v.value.isInitialized) return v.value.duration.inSeconds;
    final info = service.episodeInfo(drama, episode.value);
    return info != null && info.seconds > 0 ? info.seconds : drama.episodeSeconds(episode.value);
  }

  bool get canWatch => service.canWatch(drama, episode.value);
  double get progress => duration == 0 ? 0 : (position.value / duration).clamp(0, 1);

  void onPageChanged(int index) {
    episode.value = index + 1;
    position.value = 0;
    _start();
  }

  Future<void> _start() async {
    final token = ++_loadToken;
    pause();
    _disposeVideo();
    final url = await service.recordWatch(drama.id, episode.value);
    if (token != _loadToken || isClosed) return;
    if (url.isNotEmpty && canWatch) {
      final v = VideoPlayerController.networkUrl(Uri.parse(url));
      try {
        await v.initialize();
      } catch (_) {
        await v.dispose();
        toast("Couldn't play this episode", 'Check your connection and try again.');
        return;
      }
      if (token != _loadToken || isClosed) {
        await v.dispose();
        return;
      }
      v.addListener(() {
        position.value = v.value.position.inMilliseconds / 1000;
        if (v.value.isInitialized && !v.value.isPlaying && v.value.position >= v.value.duration) _finished();
      });
      video.value = v;
    }
    if (canWatch) play();
  }

  void _disposeVideo() {
    final v = video.value;
    video.value = null;
    v?.dispose();
  }

  void play() {
    if (!canWatch) return;
    playing.value = true;
    final v = video.value;
    if (v != null) {
      v.play();
      return;
    }
    _ticker?.cancel();
    _ticker = Timer.periodic(_tick, (_) {
      position.value += _tick.inMilliseconds / 1000;
      if (position.value >= duration) _finished();
    });
  }

  void pause() {
    playing.value = false;
    _ticker?.cancel();
    video.value?.pause();
  }

  void togglePlay() {
    if (!canWatch) return;
    playing.value ? pause() : play();
    showControls.value = true;
  }

  void seek(double fraction) {
    final target = duration * fraction.clamp(0.0, 1.0);
    position.value = target;
    video.value?.seekTo(Duration(milliseconds: (target * 1000).round()));
  }

  bool _ending = false;

  void _finished() {
    if (_ending) return;
    _ending = true;
    pause();
    position.value = duration.toDouble();
    if (episode.value < drama.episodeCount) {
      pages.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      toast('That\'s the finale', 'You\'ve watched every episode of ${drama.title}.');
    }
    Future.delayed(const Duration(milliseconds: 500), () => _ending = false);
  }

  void jumpTo(int ep) {
    Get.back();
    pages.jumpToPage(ep - 1);
  }

  Future<void> unlock() async {
    if (unlocking.value) return;
    unlocking.value = true;
    try {
      if (await service.unlock(drama, episode.value)) {
        toast('Episode ${episode.value} unlocked');
        episode.refresh();
        _start();
      } else {
        toast('Not enough coins', 'Top up to keep watching.');
        Get.toNamed(AppRoutes.topUp);
      }
    } catch (_) {
      toast("Couldn't unlock yet", 'Check your connection and try again.');
    } finally {
      unlocking.value = false;
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
    _disposeVideo();
    pages.dispose();
    super.onClose();
  }
}
