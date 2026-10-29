import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common.dart';
import 'controller/reader_controller.dart';
import 'widgets/reader_sheets.dart';

class ReaderScreen extends GetView<ReaderController> {
  const ReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = controller.settings.value.theme;
      return PopScope(
        canPop: !controller.shouldOfferShelf,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _offerShelf(context);
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: theme.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: theme.background,
            body: Stack(
              children: [
                Positioned.fill(child: _Body()),
                _TopBar(),
                _BottomBar(),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _offerShelf(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add to library?', style: TextStyle(fontSize: 17)),
        content: const Text('Keep this story on your shelf so you can pick up where you left off.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('Not now', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              controller.addToShelf();
              Get.back();
              Get.back();
            },
            child: const Text('Add', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _Body extends GetView<ReaderController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.settings.value;
      final theme = s.theme;
      final ch = controller.chapter.value;
      if (controller.isLoading.value || ch == null) return const LoadingView();

      final textStyle = GoogleFonts.getFont(
        s.fontFamily,
        fontSize: s.fontSize,
        height: s.lineHeight,
        color: theme.text,
      );
      final padding = MediaQuery.paddingOf(context);

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggleControls,
        child: ListView(
          controller: controller.scrollController,
          padding: EdgeInsets.fromLTRB(22, padding.top + 24, 22, padding.bottom + 40),
          children: [
            Text(
              controller.book.value?.title ?? '',
              style: TextStyle(color: theme.text.withValues(alpha: 0.5), fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              ch.title,
              style: GoogleFonts.getFont(s.fontFamily,
                  fontSize: s.fontSize + 6, fontWeight: FontWeight.w700, color: theme.text),
            ),
            const SizedBox(height: 24),
            if (ch.isLocked)
              _LockedCard()
            else ...[
              for (final p in ch.content.split('\n\n'))
                Padding(
                  padding: EdgeInsets.only(bottom: s.fontSize * 0.9),
                  child: Text(p, style: textStyle),
                ),
              const SizedBox(height: 24),
              _ChapterEnd(),
            ],
          ],
        ),
      );
    });
  }
}

class _ChapterEnd extends GetView<ReaderController> {
  @override
  Widget build(BuildContext context) {
    final theme = controller.settings.value.theme;
    if (!controller.hasNext) {
      return Column(
        children: [
          Icon(Icons.auto_stories_rounded, color: theme.text.withValues(alpha: 0.4), size: 36),
          const SizedBox(height: 8),
          Text(
            controller.book.value?.isCompleted == true
                ? 'The End'
                : 'You\'re all caught up. New chapters are on the way.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.text.withValues(alpha: 0.6)),
          ),
        ],
      );
    }
    return GradientButton(label: 'Next Chapter', onTap: controller.next);
  }
}

class _LockedCard extends GetView<ReaderController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.settings.value;
      final ch = controller.chapter.value!;
      final enough = controller.balance >= ch.coinPrice;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: s.theme.isDark ? const Color(0xFF26222A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.lock_rounded, color: AppColors.primary, size: 36),
            const SizedBox(height: 10),
            Text(
              'Unlock this chapter to keep reading',
              textAlign: TextAlign.center,
              style: TextStyle(color: s.theme.text, fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _row('Price', '${ch.coinPrice} coins', s.theme.text),
            _row('Balance', '${controller.coins.value} coins + ${controller.bonus.value} bonus', s.theme.text),
            const SizedBox(height: 16),
            GradientButton(
              label: enough ? 'Unlock for ${ch.coinPrice} coins' : 'Top up',
              width: double.infinity,
              loading: controller.isUnlocking.value,
              onTap: enough ? controller.unlock : controller.topUp,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text('Auto-unlock next chapters',
                      style: TextStyle(color: s.theme.text.withValues(alpha: 0.7), fontSize: 13)),
                ),
                Switch(
                  value: controller.autoUnlock,
                  onChanged: controller.setAutoUnlock,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _row(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 13)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
}

class _TopBar extends GetView<ReaderController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = controller.settings.value.theme;
      final top = MediaQuery.paddingOf(context).top;
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 200),
        top: controller.showControls.value ? 0 : -(top + 60),
        left: 0,
        right: 0,
        child: Container(
          padding: EdgeInsets.only(top: top),
          color: theme.chrome,
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.text, size: 20),
                ),
                Expanded(
                  child: Text(
                    controller.book.value?.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.text, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                IconButton(
                  onPressed: controller.toggleShelf,
                  icon: Icon(
                    controller.onShelf ? Icons.library_add_check_rounded : Icons.library_add_outlined,
                    color: controller.onShelf ? AppColors.primary : theme.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _BottomBar extends GetView<ReaderController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.settings.value;
      final theme = s.theme;
      final bottom = MediaQuery.paddingOf(context).bottom;
      final total = controller.chapters.length;

      Widget action(IconData icon, String label, VoidCallback onTap) => Expanded(
            child: InkResponse(
              onTap: onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: theme.text, size: 22),
                  const SizedBox(height: 2),
                  Text(label, style: TextStyle(color: theme.text.withValues(alpha: 0.7), fontSize: 11)),
                ],
              ),
            ),
          );

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 200),
        bottom: controller.showControls.value ? 0 : -(bottom + 140),
        left: 0,
        right: 0,
        child: Container(
          color: theme.chrome,
          padding: EdgeInsets.fromLTRB(8, 8, 8, bottom + 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: controller.hasPrev ? controller.prev : null,
                    child: Text('Prev',
                        style: TextStyle(color: theme.text.withValues(alpha: controller.hasPrev ? 1 : 0.3))),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: total == 0 ? 0 : controller.number / total,
                          color: AppColors.primary,
                          backgroundColor: theme.text.withValues(alpha: 0.12),
                          minHeight: 3,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        const SizedBox(height: 4),
                        Text('Chapter ${controller.number} of $total',
                            style: TextStyle(color: theme.text.withValues(alpha: 0.6), fontSize: 11)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: controller.hasNext ? controller.next : null,
                    child: Text('Next',
                        style: TextStyle(color: theme.text.withValues(alpha: controller.hasNext ? 1 : 0.3))),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  action(Icons.format_list_bulleted_rounded, 'Contents', () => showReaderContents(context)),
                  action(Icons.text_fields_rounded, 'Settings', () => showReaderSettings(context)),
                  action(
                    theme.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    theme.isDark ? 'Day' : 'Night',
                    controller.toggleNight,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
