import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../discover/discover_screen.dart';
import '../library/library_screen.dart';
import '../profile/profile_screen.dart';
import '../rank/rank_screen.dart';
import '../short/short_screen.dart';
import 'controller/main_controller.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            LibraryScreen(),
            DiscoverScreen(),
            ShortScreen(),
            RankScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Library already lists what you're reading; Profile has its own
            // promo slot.
            if (controller.currentIndex.value != 0 && controller.currentIndex.value != 4)
              const _ContinueReadingBar(),
            CustomBottomNav(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeTab,
              profileBadge: controller.unread,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueReadingBar extends GetView<MainController> {
  const _ContinueReadingBar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final book = controller.lastRead.value;
      if (book == null || controller.continueDismissed.value) return const SizedBox.shrink();
      return Container(
        height: 56,
        padding: const EdgeInsets.only(left: 12, right: 4),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.plum, AppColors.plumLight]),
        ),
        child: Row(
          children: [
            BookCover(book: book, width: 34, radius: 3),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text(
                    'Read to Chapter ${controller.lastChapter.value}',
                    style: const TextStyle(color: AppColors.blushDeep, fontSize: 11),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: controller.continueReading,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: AppColors.plum, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
            IconButton(
              onPressed: controller.dismissContinue,
              icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
            ),
          ],
        ),
      );
    });
  }
}
