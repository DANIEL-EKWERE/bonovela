import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/models/author_models.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/author_cover.dart';
import '../../widgets/common.dart';
import 'controller/author_stories_controller.dart';

class AuthorStoriesScreen extends GetView<AuthorStoriesController> {
  const AuthorStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: const Icon(AppIcons.arrowLeft)),
        title: const Text('Author Center'),
        actions: [
          IconButton(
            onPressed: controller.newStory,
            icon: const Icon(AppIcons.addCircle, color: AppColors.textPrimary, size: 30),
          ),
        ],
      ),
      body: Column(
        children: [
          _Tips(),
          Expanded(
            child: Obx(() {
              final stories = controller.stories;
              if (stories.isEmpty) {
                return EmptyState(
                  icon: AppIcons.write,
                  message: 'You haven\'t started a story yet.',
                  actionLabel: 'Create a story',
                  onAction: controller.newStory,
                );
              }
              return ListView.separated(
                itemCount: stories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _StoryCard(story: stories[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Tips extends GetView<AuthorStoriesController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: controller.tipsExpanded.toggle,
        child: Container(
          width: double.infinity,
          color: const Color(0xFFFFF8D9),
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'TIPS: Unsigned books cannot be displayed in the app.\n'
                  'Once a book is signed, it will be eligible to go live in the app. However, books with fewer than '
                  '20 chapters cannot go live, even after signing.\n\n'
                  'Need more information?\nPlease contact your assigned Editor for assistance.',
                  maxLines: controller.tipsExpanded.value ? null : 1,
                  overflow: controller.tipsExpanded.value ? null : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
              Icon(
                controller.tipsExpanded.value ? AppIcons.caretUp : AppIcons.caretDown,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends GetView<AuthorStoriesController> {
  final AuthorStory story;

  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    final complete = story.isInfoComplete;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Last Update: ${Fmt.date(controller.lastUpdate(story))}',
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _showMenu(context),
                icon: const Icon(AppIcons.more, color: AppColors.textSecondary),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => controller.openChapters(story),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthorCover(story: story, width: 72),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [
                          _Chip(story.completed ? 'Completed' : 'Ongoing', AppColors.primary),
                          _Chip(story.signed ? 'Signed' : 'Unsigned', AppColors.textSecondary),
                          if (story.applicationStatus.isNotEmpty) _Chip(story.applicationStatus, AppColors.gold),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => Wrap(
                          spacing: 18,
                          runSpacing: 6,
                          children: [
                            _Stat(AppIcons.heartFill, '${controller.likes(story)}'),
                            _Stat(AppIcons.eye, Fmt.compact(controller.views(story))),
                            _Stat(AppIcons.textSettings, Fmt.compact(controller.words(story))),
                            _Stat(AppIcons.libraryAdded, '${controller.chapterCount(story)}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (complete)
            Obx(
              () => Row(
                children: [
                  // Appears once the book reaches the contract word count.
                  if (controller.canApply(story))
                    TextButton(
                      onPressed: () => controller.applyForContract(story),
                      child: const Text('Apply for Contract ›'),
                    )
                  else if (!story.signed && story.applicationStatus.isEmpty)
                    Expanded(
                      child: Text(
                        'Apply for Contract at ${AppConstants.contractMinWords} published words '
                        '(${controller.words(story)} so far).',
                        style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                      ),
                    ),
                  const Spacer(),
                  GradientButton(
                    label: 'Add new chapter',
                    height: 36,
                    fontSize: 13,
                    onTap: () => controller.addChapter(story),
                  ),
                ],
              ),
            )
          else ...[
            const Text(
              'Please complete your book information before you publish it.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GradientButton(
                label: 'Complete the info',
                height: 36,
                fontSize: 13,
                onTap: () => controller.editStory(story),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(story.displayTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: const Icon(AppIcons.edit),
              title: const Text('Edit Story'),
              onTap: () {
                Get.back();
                controller.editStory(story);
              },
            ),
            ListTile(
              leading: const Icon(AppIcons.delete, color: AppColors.error),
              title: const Text('Delete Story', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Get.back();
                Get.defaultDialog(
                  title: 'Delete story?',
                  middleText: '"${story.displayTitle}" and all its chapters will be deleted.',
                  textCancel: 'Cancel',
                  textConfirm: 'Delete',
                  confirmTextColor: Colors.white,
                  buttonColor: AppColors.error,
                  cancelTextColor: AppColors.textSecondary,
                  onConfirm: () {
                    Get.back();
                    controller.deleteStory(story);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
    decoration: BoxDecoration(
      border: Border.all(color: color.withValues(alpha: 0.5)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, color: color)),
  );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _Stat(this.icon, this.value);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: AppColors.textHint),
      const SizedBox(width: 4),
      Text(value, style: const TextStyle(fontSize: 13)),
    ],
  );
}
