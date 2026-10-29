import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/comment_tile.dart';
import '../../widgets/ui_kit.dart';
import 'controller/comments_controller.dart';

class CommentsScreen extends GetView<CommentsController> {
  const CommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Reviews',
      background: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final list = controller.comments;
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Row(
                      children: [
                        Text(controller.average.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StarRow(stars: controller.average.round(), size: 18),
                            Text('${list.length} reviews',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  for (final c in list)
                    CommentTile(
                      comment: c,
                      liked: controller.liked.contains(c.id),
                      onLike: () => controller.toggleLike(c),
                    ),
                ],
              );
            }),
          ),
          _Composer(),
        ],
      ),
    );
  }
}

class _Composer extends GetView<CommentsController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => Row(
                    children: [
                      const Text('Your rating', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(width: 8),
                      for (var i = 1; i <= 5; i++)
                        GestureDetector(
                          onTap: () => controller.stars.value = i,
                          child: Icon(
                            i <= controller.stars.value ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                    ],
                  )),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.textController,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'What do you think?', isDense: true),
                    ),
                  ),
                  IconButton(onPressed: controller.post, icon: const Icon(Icons.send_rounded, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
