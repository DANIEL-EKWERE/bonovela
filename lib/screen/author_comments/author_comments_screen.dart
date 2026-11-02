import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/models/author_models.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/comment_tile.dart';
import '../../widgets/common.dart';
import 'controller/author_comments_controller.dart';

class AuthorCommentsScreen extends GetView<AuthorCommentsController> {
  const AuthorCommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: const Icon(AppIcons.arrowLeft)),
        title: const Text('Comment Management'),
      ),
      body: Obx(() {
        final list = controller.comments;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _Filter(
                      label: controller.storyFilter.value == null
                          ? 'All books'
                          : controller.storyTitle(controller.storyFilter.value!),
                      options: [
                        ('All books', () => controller.storyFilter.value = null),
                        for (final s in controller.stories) (s.displayTitle, () => controller.storyFilter.value = s.id),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Filter(
                      label: controller.starFilter.value == 0 ? 'All ratings' : '${controller.starFilter.value} stars',
                      options: [
                        ('All ratings', () => controller.starFilter.value = 0),
                        for (final n in [5, 4, 3, 2, 1]) ('$n stars', () => controller.starFilter.value = n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Text('${list.length}', style: const TextStyle(color: AppColors.textHint)),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(
                      icon: AppIcons.chat,
                      message: 'No comments yet.\nPublish chapters to hear from readers.',
                    )
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const Divider(indent: 16, endIndent: 16),
                      itemBuilder: (_, i) => _CommentRow(comment: list[i]),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _Filter extends StatelessWidget {
  final String label;
  final List<(String, VoidCallback)> options;

  const _Filter({required this.label, required this.options});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: Colors.white,
      onSelected: (i) => options[i].$2(),
      itemBuilder: (_) => [for (final (i, (l, _)) in options.indexed) PopupMenuItem(value: i, child: Text(l))],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
            const Icon(AppIcons.caretDown, size: 16),
          ],
        ),
      ),
    );
  }
}

class _CommentRow extends GetView<AuthorCommentsController> {
  final AuthorComment comment;

  const _CommentRow({required this.comment});

  @override
  Widget build(BuildContext context) {
    final c = comment;
    return InkWell(
      onTap: () => _openThread(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.blushDeep,
              child: Text(
                c.user[0],
                style: const TextStyle(color: AppColors.plum, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.user, style: const TextStyle(fontWeight: FontWeight.w600)),
                  StarRow(stars: c.stars),
                  Text(
                    '${controller.storyTitle(c.storyId)} / ${c.chapterTitle}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                  const SizedBox(height: 6),
                  Text(c.text, style: const TextStyle(fontSize: 14, height: 1.4)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(Fmt.date(c.date), style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                      const Spacer(),
                      const Icon(AppIcons.heart, size: 16, color: AppColors.textHint),
                      Text(' ${c.likes}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                      const SizedBox(width: 14),
                      const Icon(AppIcons.chat, size: 16, color: AppColors.textHint),
                      Text(
                        ' ${controller.repliesOf(c).length}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openThread(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.6,
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  final replies = controller.repliesOf(comment);
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(comment.user, style: const TextStyle(fontWeight: FontWeight.w600)),
                      StarRow(stars: comment.stars),
                      const SizedBox(height: 8),
                      Text(comment.text, style: const TextStyle(fontSize: 15, height: 1.4)),
                      const Divider(height: 28),
                      if (replies.isEmpty) const Text('No replies yet.', style: TextStyle(color: AppColors.textHint)),
                      for (final r in replies)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(10)),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Author: ',
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                                TextSpan(text: r),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.replyController,
                          decoration: const InputDecoration(hintText: 'Leave a comment', isDense: true),
                          onSubmitted: (_) => controller.reply(comment),
                        ),
                      ),
                      IconButton(
                        onPressed: () => controller.reply(comment),
                        icon: const Icon(AppIcons.send, color: AppColors.primary),
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
