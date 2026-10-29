import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/models/comment_model.dart';
import '../core/utils/formatters.dart';

class StarRow extends StatelessWidget {
  final int stars;
  final double size;

  const StarRow({super.key, required this.stars, this.size = 14});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(i <= stars ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.primary, size: size),
        ],
      );
}

/// One review. Used on Book detail and the Reviews screen.
class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool liked;
  final VoidCallback? onLike;

  const CommentTile({super.key, required this.comment, this.liked = false, this.onLike});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: comment.isMine ? AppColors.plum : AppColors.blushDeep,
            child: Text(comment.userName[0],
                style: TextStyle(color: comment.isMine ? Colors.white : AppColors.plum, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (comment.isMine)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(6)),
                        child: const Text('You', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                      ),
                  ],
                ),
                StarRow(stars: comment.stars),
                const SizedBox(height: 6),
                Text(comment.text, style: const TextStyle(fontSize: 14, height: 1.4)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(Fmt.ago(comment.date), style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    const Spacer(),
                    GestureDetector(
                      onTap: onLike,
                      child: Row(
                        children: [
                          Icon(liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 18, color: liked ? AppColors.primary : AppColors.textHint),
                          const SizedBox(width: 3),
                          Text('${comment.likes + (liked ? 1 : 0)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
