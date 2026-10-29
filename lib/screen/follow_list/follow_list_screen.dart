import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common.dart';
import 'controller/follow_list_controller.dart';

class FollowListScreen extends GetView<FollowListController> {
  const FollowListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: controller.initialTab,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
          title: const Text('Follow'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            labelColor: AppColors.primary,
            tabs: [Tab(text: 'Followers'), Tab(text: 'Following')],
          ),
        ),
        body: TabBarView(
          children: [
            const EmptyState(icon: Icons.favorite_border_rounded, message: 'You have no followers yet.'),
            Obx(() {
              final list = controller.following.toList();
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.person_add_alt_rounded,
                  message: 'Follow authors you love to see their new stories first.',
                );
              }
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => _AuthorRow(author: list[i]),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _AuthorRow extends GetView<FollowListController> {
  final String author;

  const _AuthorRow({required this.author});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => controller.openAuthor(author),
      leading: CircleAvatar(
        backgroundColor: AppColors.plum,
        child: Text(author[0], style: const TextStyle(color: Colors.white)),
      ),
      title: Text(author, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${controller.storyCount(author)} stories', style: const TextStyle(fontSize: 12)),
      trailing: Obx(() {
        final on = controller.following.contains(author);
        return OutlinedButton.icon(
          onPressed: () => controller.toggle(author),
          icon: Icon(on ? Icons.check_rounded : Icons.add_rounded, size: 16),
          label: Text(on ? 'Following' : 'Follow'),
          style: OutlinedButton.styleFrom(
            foregroundColor: on ? AppColors.textSecondary : AppColors.primary,
            side: BorderSide(color: on ? AppColors.divider : AppColors.primary),
            shape: const StadiumBorder(),
            visualDensity: VisualDensity.compact,
          ),
        );
      }),
    );
  }
}
