import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common.dart';
import 'controller/discover_controller.dart';
import 'widgets/feed_section_view.dart';

class DiscoverScreen extends GetView<DiscoverController> {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: HeaderBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                child: Row(
                  children: [
                    Expanded(child: SearchBarButton(onTap: controller.openSearch)),
                    const SizedBox(width: 4),
                    _HeaderAction(
                      icon: Icons.card_giftcard_rounded,
                      label: 'Rewards',
                      onTap: controller.openRewards,
                    ),
                  ],
                ),
              ),
              TabBar(
                isScrollable: true,
                controller: controller.tabController,
                tabs: [for (final t in controller.tabs) Tab(text: t, height: 40)],
              ),
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: [for (final t in controller.tabs) _TabFeed(tab: t)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _TabFeed extends GetView<DiscoverController> {
  final String tab;

  const _TabFeed({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sections = controller.feeds[tab];
      if (sections == null) return const LoadingView();
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => controller.refreshTab(tab),
        child: ListView(
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          children: [for (final s in sections) FeedSectionView(section: s)],
        ),
      );
    });
  }
}
