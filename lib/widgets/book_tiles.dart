import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/routes.dart';
import '../core/constants/app_colors.dart';
import '../core/models/book_model.dart';
import '../core/utils/formatters.dart';
import 'book_cover.dart';
import 'common.dart';

void openBook(BookModel book) =>
    Get.toNamed(AppRoutes.bookDetail, arguments: book.id, preventDuplicates: false);

/// Cover with title and tag beneath it. Used in horizontal rows and grids.
class BookGridTile extends StatelessWidget {
  /// Height a horizontal row needs for tiles of [width].
  static double rowHeight(double width) => width * 4 / 3 + 70;

  final BookModel book;
  final double width;
  final String? subtitle;
  final String? badge;

  const BookGridTile({super.key, required this.book, this.width = 100, this.subtitle, this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openBook(book),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(book: book, width: width, badge: badge ?? (book.isShort ? 'Short' : null)),
            const SizedBox(height: 6),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.25),
            ),
            const SizedBox(height: 2),
            subtitle != null
                ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.textHint))
                : TagText([book.primaryTag], max: 1),
          ],
        ),
      ),
    );
  }
}

/// Cover on the left; title, synopsis, tags and views on the right.
class BookListTile extends StatelessWidget {
  final BookModel book;
  final int? rank;
  final bool showRating;
  final bool coverOnRight;

  const BookListTile({
    super.key,
    required this.book,
    this.rank,
    this.showRating = false,
    this.coverOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final cover = BookCover(
      book: book,
      width: 84,
      rank: rank,
      showRating: !coverOnRight,
      badge: coverOnRight && book.isShort ? 'Short' : null,
    );
    final info = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.25),
          ),
          const SizedBox(height: 4),
          Text(
            book.synopsis,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 6),
          if (showRating)
            Row(
              children: [
                RatingStars(rating: book.rating, size: 13),
                const Spacer(),
                const Icon(Icons.visibility_outlined, size: 14, color: AppColors.star),
                const SizedBox(width: 3),
                Text(Fmt.compact(book.views),
                    style: const TextStyle(fontSize: 11, color: AppColors.star)),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: TagText(book.tags)),
                Text(Fmt.views(book.views),
                    style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
        ],
      ),
    );

    return InkWell(
      onTap: () => openBook(book),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: coverOnRight
              ? [info, const SizedBox(width: 12), cover]
              : [cover, const SizedBox(width: 12), info],
        ),
      ),
    );
  }
}

/// Compact row: small cover, title, one tag. Used in two-column ranked grids.
class BookCompactTile extends StatelessWidget {
  final BookModel book;
  final int? rank;
  final double width;

  const BookCompactTile({super.key, required this.book, this.rank, this.width = 220});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openBook(book),
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            BookCover(book: book, width: 62, rank: rank),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.25),
                  ),
                  const SizedBox(height: 8),
                  TagChip(book.primaryTag),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
