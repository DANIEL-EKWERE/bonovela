import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/common.dart';
import 'controller/drama_player_controller.dart';
import 'widgets/episodes_sheet.dart';

class DramaPlayerScreen extends GetView<DramaPlayerController> {
  const DramaPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final d = controller.drama;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: controller.pages,
              scrollDirection: Axis.vertical,
              itemCount: d.episodeCount,
              onPageChanged: controller.onPageChanged,
              itemBuilder: (_, i) => _EpisodePage(episode: i + 1),
            ),
            SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(AppIcons.back, color: Colors.white),
                  ),
                  Expanded(
                    child: Obx(
                      () => Text(
                        '${d.title} · EP ${controller.episode.value}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One episode: poster as the "video", play/pause, side actions, caption,
/// progress bar, or the unlock card when the episode is locked.
class _EpisodePage extends GetView<DramaPlayerController> {
  final int episode;

  const _EpisodePage({required this.episode});

  @override
  Widget build(BuildContext context) {
    final d = controller.drama;
    final size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: controller.togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BookCover(book: d.asBook, width: size.width, height: size.height, radius: 0),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black45, Colors.transparent, Colors.transparent, Colors.black87],
                stops: [0, 0.2, 0.55, 1],
              ),
            ),
          ),
          Obx(() {
            final current = controller.episode.value == episode;
            controller.service.unlocked.length; // rebuild after unlocks
            controller.account.plusUntil.value;
            if (!current) return const SizedBox.shrink();
            if (!controller.canWatch) return const _LockedCard();
            return Center(
              child: AnimatedOpacity(
                opacity: controller.playing.value ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                  child: const Icon(AppIcons.playFill, color: Colors.white, size: 36),
                ),
              ),
            );
          }),
          Positioned(right: 10, bottom: 130, child: _SideActions()),
          Positioned(
            left: 16,
            right: 80,
            bottom: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.title,
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Episode $episode / ${d.episodeCount}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  d.synopsis,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
                ),
                if (d.bookId != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: controller.readNovel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppIcons.book, size: 14, color: Colors.white),
                          SizedBox(width: 5),
                          Text('Read the novel', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: SafeArea(top: false, child: _ProgressBar(episode))),
        ],
      ),
    );
  }
}

class _SideActions extends GetView<DramaPlayerController> {
  @override
  Widget build(BuildContext context) {
    final d = controller.drama;
    return Column(
      children: [
        Obx(() {
          final saved = controller.service.isSaved(d.id);
          return _Action(
            icon: saved ? AppIcons.libraryAdded : AppIcons.libraryAdd,
            label: saved ? 'Saved' : 'Save',
            color: saved ? AppColors.primary : Colors.white,
            onTap: () => controller.service.toggleSaved(d.id),
          );
        }),
        _Action(
          icon: AppIcons.episodes,
          label: 'Episodes',
          onTap: () => Get.bottomSheet(
            const EpisodesSheet(),
            backgroundColor: Colors.white,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          ),
        ),
        _Action(icon: AppIcons.eye, label: Fmt.compact(d.plays), onTap: () {}),
        _Action(icon: AppIcons.share, label: 'Share', onTap: () {}),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _Action({required this.icon, required this.label, required this.onTap, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30, shadows: const [Shadow(blurRadius: 6, color: Colors.black54)]),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends GetView<DramaPlayerController> {
  final int episode;

  const _ProgressBar(this.episode);

  static String _mmss(num s) => '${s ~/ 60}:${(s.toInt() % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.episode.value == episode;
      final value = current ? controller.progress : 0.0;
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 16, 6),
        child: Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.5,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: SliderComponentShape.noOverlay,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                ),
                child: Slider(value: value, onChanged: current && controller.canWatch ? controller.seek : null),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${_mmss(current ? controller.position.value : 0)} / ${_mmss(controller.drama.episodeSeconds(episode))}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      );
    });
  }
}

class _LockedCard extends GetView<DramaPlayerController> {
  const _LockedCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.lockFill, color: AppColors.primary, size: 34),
            const SizedBox(height: 10),
            Text(
              'Episode ${controller.episode.value} is locked',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Obx(
              () => Text(
                'Balance: ${controller.account.coins.value} coins · ${controller.account.bonus.value} bonus',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            GradientButton(label: 'Unlock for ${controller.priceLabel}', onTap: controller.unlock),
            const SizedBox(height: 8),
            TextButton(
              onPressed: controller.getPlus,
              child: const Text('Watch every episode free with Plus'),
            ),
          ],
        ),
      ),
    );
  }
}
