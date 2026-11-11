import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import '../author_calendar/author_calendar_screen.dart';
import '../author_comments/author_comments_screen.dart';
import '../author_discover/author_discover_screen.dart';
import '../author_income/author_income_screen.dart';
import '../author_stories/author_stories_screen.dart';
import 'controller/author_center_controller.dart';

class AuthorCenterScreen extends GetView<AuthorCenterController> {
  const AuthorCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isAuthor) return const SubPage(title: 'Author Center', body: _Intro());
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: IndexedStack(
          index: controller.tab.value,
          children: const [
            AuthorStoriesScreen(),
            AuthorDiscoverScreen(),
            AuthorCalendarScreen(),
            AuthorCommentsScreen(),
            AuthorIncomeScreen(),
          ],
        ),
        bottomNavigationBar: _AuthorNav(index: controller.tab.value, onTap: controller.changeTab),
      );
    });
  }
}

class _AuthorNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _AuthorNav({required this.index, required this.onTap});

  static const _items = [
    (AppIcons.library, AppIcons.libraryFill, 'Stories'),
    (AppIcons.gift, AppIcons.gift, 'Benefits'),
    (AppIcons.calendar, AppIcons.calendarFill, 'Calendar'),
    (AppIcons.chat, AppIcons.chatFill, 'Comments'),
    (AppIcons.income, AppIcons.wallet, 'Income'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (final (i, (icon, active, label)) in _items.indexed)
                Expanded(
                  child: InkResponse(
                    onTap: () => onTap(i),
                    highlightShape: BoxShape.rectangle,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          i == index ? active : icon,
                          size: 24,
                          color: i == index ? AppColors.primary : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: i == index ? FontWeight.w600 : FontWeight.w400,
                            color: i == index ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Intro extends GetView<AuthorCenterController> {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    const perks = [
      (AppIcons.payments, 'Earn from every unlock', 'Get a share of coins spent on your chapters.'),
      (AppIcons.megaphone, 'Get featured', 'Top new stories are promoted on Discover.'),
      (AppIcons.insights, 'Track your readers', 'See reads, comments and income in one place.'),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(AppIcons.write, size: 72, color: AppColors.primary),
        const SizedBox(height: 8),
        const Text(
          'Write on Bonovela',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Share your stories with readers who can\'t wait for the next chapter.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        for (final (icon, title, body) in perks)
          WhiteCard(
            child: Row(
              children: [
                Icon(icon, color: AppColors.plumLight, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        GradientButton(label: 'Become an author', onTap: controller.becomeAuthor),
      ],
    );
  }
}
