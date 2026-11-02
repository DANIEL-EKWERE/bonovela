import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/models/author_models.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common.dart';
import 'controller/story_chapters_controller.dart';

class StoryChaptersScreen extends GetView<StoryChaptersController> {
  const StoryChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(onPressed: Get.back, icon: const Icon(AppIcons.back, size: 20)),
          title: Text(controller.story?.displayTitle ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(onPressed: controller.editInfo, icon: const Icon(AppIcons.edit)),
            IconButton(onPressed: controller.openStats, icon: const Icon(AppIcons.stats)),
          ],
          bottom: const TabBar(
            isScrollable: false,
            tabAlignment: TabAlignment.fill,
            tabs: [
              Tab(text: 'Draft'),
              Tab(text: 'Published'),
              Tab(text: 'Trash'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.newChapter,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(AppIcons.add, size: 28),
        ),
        body: const TabBarView(
          children: [
            _ChapterList(status: ChapterStatus.draft),
            _ChapterList(status: ChapterStatus.published),
            _ChapterList(status: ChapterStatus.trash),
          ],
        ),
      ),
    );
  }
}

class _ChapterList extends GetView<StoryChaptersController> {
  final ChapterStatus status;

  const _ChapterList({required this.status});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.list(status);
      if (list.isEmpty) return const EmptyState(icon: AppIcons.book, message: 'Sorry! No data found.');
      return ListView.separated(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final c = list[i];
          return InkWell(
            onTap: status == ChapterStatus.trash ? null : () => controller.edit(c),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.title.isEmpty ? c.label : '${c.label}  ${c.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Words: ${Fmt.compact(c.words)}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        Text(Fmt.date(c.updatedAt), style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _menu(context, c),
                    icon: const Icon(AppIcons.more, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _menu(BuildContext context, AuthorChapter c) {
    Widget item(IconData icon, String label, VoidCallback onTap, {Color? color}) => ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: () {
        Get.back();
        onTap();
      },
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            if (status != ChapterStatus.trash) item(AppIcons.edit, 'Edit', () => controller.edit(c)),
            if (status == ChapterStatus.draft) item(AppIcons.send, 'Publish', () => controller.publish(c)),
            if (status != ChapterStatus.trash)
              item(AppIcons.delete, 'Move to Trash', () => controller.trash(c), color: AppColors.error),
            if (status == ChapterStatus.trash) ...[
              item(AppIcons.restore, 'Restore', () => controller.restore(c)),
              item(AppIcons.delete, 'Delete forever', () => controller.deleteForever(c), color: AppColors.error),
            ],
          ],
        ),
      ),
    );
  }
}
