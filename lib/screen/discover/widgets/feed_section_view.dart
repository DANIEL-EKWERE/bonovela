import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/book_model.dart';
import '../../../widgets/book_cover.dart';
import '../../../widgets/book_tiles.dart';
import '../../../widgets/common.dart';
import '../models/feed_section.dart';

/// Renders one [FeedSection] according to its layout, inside a white card.
class FeedSectionView extends StatelessWidget {
  final FeedSection section;

  const FeedSectionView({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    if (section.books.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: section.title,
            onMore: section.books.length > 3
                ? () => Get.toNamed(AppRoutes.viewAll, arguments: {'title': section.title, 'books': section.books})
                : null,
          ),
          switch (section.layout) {
            FeedLayout.rankedColumns => _RankedColumns(books: section.books),
            FeedLayout.coverRow => _CoverRow(books: section.books),
            FeedLayout.detailList => Column(
                children: [for (final b in section.books) BookListTile(book: b)],
              ),
            FeedLayout.hero => _Hero(books: section.books),
            FeedLayout.compactGrid => _CompactGrid(books: section.books),
            FeedLayout.ratedList => Column(
                children: [for (final b in section.books) BookListTile(book: b, showRating: true)],
              ),
          },
        ],
      ),
    );
  }
}

class _CoverRow extends StatelessWidget {
  final List<BookModel> books;

  const _CoverRow({required this.books});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: BookGridTile.rowHeight(100),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => BookGridTile(book: books[i], width: 100),
      ),
    );
  }
}

/// Pages of four numbered rows, swiped horizontally.
class _RankedColumns extends StatelessWidget {
  final List<BookModel> books;

  const _RankedColumns({required this.books});

  @override
  Widget build(BuildContext context) {
    final pages = <List<int>>[];
    for (var i = 0; i < books.length; i += 4) {
      pages.add(List.generate((books.length - i).clamp(0, 4), (k) => i + k));
    }
    final width = MediaQuery.sizeOf(context).width * 0.82;
    return SizedBox(
      // Four rows of a 62×83 cover plus 10 spacing.
      height: 4 * 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pages.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, p) => SizedBox(
          width: width,
          child: Column(
            children: [
              for (final i in pages[p])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => openBook(books[i]),
                    child: Row(
                      children: [
                        BookCover(book: books[i], width: 62, rank: i + 1),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                books[i].title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(child: TagText(books[i].tags)),
                                  Text(
                                    '${(books[i].views / 1000).round()}K Views',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                                  ),
                                ],
                              ),
                            ],
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

class _CompactGrid extends StatelessWidget {
  final List<BookModel> books;

  const _CompactGrid({required this.books});

  @override
  Widget build(BuildContext context) {
    final half = (MediaQuery.sizeOf(context).width - 32 - 12) / 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 14,
        children: [
          for (var i = 0; i < books.length; i++)
            BookCompactTile(book: books[i], rank: i + 1, width: half),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final List<BookModel> books;

  const _Hero({required this.books});

  @override
  Widget build(BuildContext context) {
    final hero = books.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => openBook(hero),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(book: hero, width: 100),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 133,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.plum, AppColors.plumLight]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hero.synopsis,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            hero.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              RatingStars(rating: hero.rating),
              const SizedBox(width: 12),
              for (final t in hero.tags.take(2))
                Padding(padding: const EdgeInsets.only(right: 6), child: TagChip(t)),
              const Spacer(),
              GradientButton(
                label: 'Read Now',
                height: 34,
                fontSize: 13,
                onTap: () => openBook(hero),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _CoverRow(books: books.skip(1).toList()),
      ],
    );
  }
}
