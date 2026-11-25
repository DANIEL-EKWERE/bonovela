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
            icon: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.incomeGradient),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
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
                return RefreshIndicator(
                  onRefresh: controller.refreshStories,
                  child: ListView(
                    children: [
                      const SizedBox(height: 80),
                      EmptyState(
                        icon: AppIcons.write,
                        message: 'You haven\'t started a story yet.',
                        actionLabel: 'Create a story',
                        onAction: controller.newStory,
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refreshStories,
                child: ListView.separated(
                  itemCount: stories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _StoryCard(story: stories[i]),
                ),
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
          color: AppColors.incomeTint,
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'TIPS: Unsigned books cannot be displayed in the app.\n\n'
                  'Once a book is signed, it will automatically be added to the Free Reading Section, where readers '
                  'can access it for free.\n\n'
                  'When a book reaches 30,000 words, the Pay-to-Read Application option will become available. '
                  'Authors who wish to monetize their books can submit an application for editorial review and '
                  'approval.\n\n'
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
                          if (story.signed)
                            _Chip('Signed', AppColors.success)
                          else if (story.applicationStatus == 'rejected')
                            _Chip('Rejected', AppColors.error)
                          else if (const {'contract_sent', 'author_signed'}.contains(story.applicationStatus))
                            _Chip('Contract Approved', AppColors.success)
                          else
                            _Chip('Unsigned', AppColors.textSecondary),
                          if (const {'pending', 'se_approved', 'revision'}.contains(story.applicationStatus) &&
                              !story.signed)
                            _Chip(story.applicationLabel, AppColors.gold),
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
                  // Appears once the book reaches the contract word count
                  // (a rejected book shows its own button in the panel below).
                  if (controller.canApply(story) && story.applicationStatus != 'rejected')
                    TextButton(
                      onPressed: () => controller.applyForContract(story),
                      child: const Text('Apply for Contract ›'),
                    )
                  else if (story.applicationStatus == 'contract_sent' && !story.signed)
                    TextButton(
                      onPressed: () => controller.reviewContract(story),
                      child: const Text('Review & sign contract ›'),
                    )
                  else if (!story.signed && story.mayApply && story.applicationStatus != 'rejected')
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
                    gradient: AppColors.incomeGradient,
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
          // Contract application state (any book) and Pay-to-Read (signed novels).
          if (!story.signed && story.applicationTitle.isNotEmpty) _ApplicationPanel(story: story),
          if (story.signed) _PayToReadPanel(story: story),
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
            if (story.canDelete && !story.signed)
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
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Text(
                  story.lockReason.isNotEmpty ? story.lockReason : "Signed books can't be deleted.",
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
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

/// "Applied:", "Application Closed:" (with the reason and Apply for contract
/// after 24 hours) or "Contract Sent to Your email".
class _ApplicationPanel extends GetView<AuthorStoriesController> {
  final AuthorStory story;

  const _ApplicationPanel({required this.story});

  @override
  Widget build(BuildContext context) {
    final rejected = story.applicationStatus == 'rejected';
    final sent = const {'contract_sent', 'author_signed'}.contains(story.applicationStatus);
    final color = rejected ? const Color(0xFFB85C00) : (sent ? const Color(0xFF1E8449) : AppColors.textPrimary);
    final wait = story.reapplyAt?.difference(DateTime.now());
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rejected ? AppColors.incomeTint : (sent ? const Color(0xFFEAF8EF) : AppColors.surface),
        border: rejected ? Border.all(color: const Color(0xFFFFD8A8)) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            story.applicationTitle,
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
          if (story.applicationMessage.isNotEmpty) const SizedBox(height: 4),
          if (story.applicationMessage.isNotEmpty)
            Text(
              story.applicationMessage,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: rejected ? AppColors.incomeText : AppColors.textSecondary,
              ),
            ),
          if (rejected) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: story.mayApply
                  ? FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F6CF7)),
                      onPressed: () => controller.applyForContract(story),
                      child: const Text('Apply for contract'),
                    )
                  : Text(
                      'You can apply again in ${wait == null ? 24 : (wait.inMinutes / 60).ceil()} hours.',
                      style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pay-to-Read: apply at 30,000 words, then Pending Review / Approved.
class _PayToReadPanel extends GetView<AuthorStoriesController> {
  final AuthorStory story;

  const _PayToReadPanel({required this.story});

  @override
  Widget build(BuildContext context) {
    final String title;
    final String message;
    if (story.paidFromChapter != null) {
      title = 'Approved – Pay-to-Read';
      message = 'Chapters from ${story.paidFromChapter} onward are locked.';
    } else if (story.payToReadStatus == 'pending') {
      title = 'Pay-to-Read: Pending Review';
      message = 'Your editor is reviewing your application.';
    } else if (story.canApplyPayToRead) {
      title = 'Pay-to-Read Application';
      message = 'Your book has reached ${story.isShort ? '5,000' : '30,000'} words. You can now apply to monetize it.';
    } else {
      return const SizedBox.shrink();
    }
    final approved = story.paidFromChapter != null;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: approved ? const Color(0xFFEAF8EF) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w700, color: approved ? const Color(0xFF1E8449) : null),
          ),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          if (story.canApplyPayToRead && !approved)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => controller.applyPayToRead(story),
                child: const Text('Apply for Pay-to-Read ›'),
              ),
            ),
        ],
      ),
    );
  }
}
