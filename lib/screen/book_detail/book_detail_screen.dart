import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/book_model.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/book_tiles.dart';
import '../../widgets/comment_tile.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/book_detail_controller.dart';
import 'widgets/chapter_list_sheet.dart';

class BookDetailScreen extends GetView<BookDetailController> {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  String? get tag => bookId;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final book = controller.book.value;
      if (controller.isLoading.value && book == null) {
        return const Scaffold(body: LoadingView());
      }
      if (book == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const EmptyState(icon: Icons.search_off_rounded, message: 'This book is no longer available.'),
        );
      }
      final palette = AppColors.coverPalettes[book.coverSeed % AppColors.coverPalettes.length];
      return Scaffold(
        backgroundColor: AppColors.surface,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: controller.collapsed.value ? Colors.white : Colors.transparent,
          foregroundColor: controller.collapsed.value ? AppColors.textPrimary : Colors.white,
          centerTitle: false,
          title: controller.collapsed.value
              ? Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15))
              : null,
          actions: [
            IconButton(onPressed: controller.report, icon: const Icon(Icons.outlined_flag_rounded)),
            IconButton(onPressed: controller.share, icon: const Icon(Icons.share_outlined)),
          ],
        ),
        body: ListView(
          controller: controller.scrollController,
          padding: EdgeInsets.zero,
          children: [
            _Header(book: book, palette: palette),
            Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Column(
                  children: [
                    _StatsCard(book: book),
                    _SynopsisCard(book: book, bookId: bookId),
                    _SupportCard(bookId: bookId),
                    _AuthorCard(book: book, bookId: bookId),
                    if (controller.related.isNotEmpty) _RelatedCard(books: controller.related),
                    _CommentsCard(bookId: bookId),
                    _PreviewCard(book: book, bookId: bookId),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _BottomBar(bookId: bookId),
      );
    });
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: padding,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: child,
      );
}

class _Header extends StatelessWidget {
  final BookModel book;
  final List<Color> palette;

  const _Header({required this.book, required this.palette});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + kToolbarHeight;
    return Container(
      padding: EdgeInsets.fromLTRB(16, top, 16, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette[0], Color.lerp(palette[1], AppColors.plum, 0.4)!],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(book: book, width: 110),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700, height: 1.25),
                ),
                const SizedBox(height: 6),
                Text(book.author, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text('Language: English | ${book.ageRating}+',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                Text(
                  '${Fmt.compact(book.wordCount)} Words | ${book.isCompleted ? 'Completed' : 'Ongoing'}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final BookModel book;

  const _StatsCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Fmt.compact(book.views), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const Text('Views', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RatingStars(rating: book.rating, size: 16),
              const Text('Rating', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SynopsisCard extends GetView<BookDetailController> {
  final BookModel book;
  final String bookId;

  @override
  String? get tag => bookId;

  const _SynopsisCard({required this.book, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => controller.synopsisExpanded.toggle(),
            child: Obx(() => Text(
                  book.synopsis,
                  maxLines: controller.synopsisExpanded.value ? null : 3,
                  overflow: controller.synopsisExpanded.value ? null : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                )),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [for (final t in [book.genre, ...book.tags]) TagChip(t)],
          ),
          const Divider(height: 24),
          InkWell(
            onTap: () => showChapterList(context, controller),
            child: Row(
              children: [
                Text('${book.chapterCount} Chapters',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const Spacer(),
                Text(
                  book.isCompleted ? 'Completed' : 'Updated ${Fmt.ago(book.updatedAt)}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorCard extends GetView<BookDetailController> {
  final BookModel book;
  final String bookId;

  const _AuthorCard({required this.book, required this.bookId});

  @override
  String? get tag => bookId;

  @override
  Widget build(BuildContext context) {
    final count = MockData.booksBy(book.author).length;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About the Author', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          InkWell(
            onTap: controller.openAuthor,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.plum,
                  child: Text(book.author[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.author, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '$count ${count == 1 ? 'Story' : 'Stories'} | Followers ${Fmt.compact(MockData.followersOf(book.author))}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Obx(() => controller.followingAuthor
                    ? OutlinedButton(
                        onPressed: controller.toggleFollowAuthor,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.divider),
                          shape: const StadiumBorder(),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Following'),
                      )
                    : GradientButton(label: 'Follow', height: 32, fontSize: 13, onTap: controller.toggleFollowAuthor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends GetView<BookDetailController> {
  final String bookId;

  const _SupportCard({required this.bookId});

  @override
  String? get tag => bookId;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Support', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.redeem_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Obx(() => Text('${controller.supporters} readers supported this book',
                    style: const TextStyle(fontSize: 14))),
              ),
              GradientButton(label: 'Support', height: 32, fontSize: 13, onTap: () => _showGifts(context)),
            ],
          ),
        ],
      ),
    );
  }

  void _showGifts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Send a gift', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Gifts go straight to the author and help keep the chapters coming.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (final g in BookDetailController.giftOptions)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.support(g),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: [
                              const CurrencyIcon('coins', size: 26),
                              const SizedBox(height: 4),
                              Text('$g', style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentsCard extends GetView<BookDetailController> {
  final String bookId;

  const _CommentsCard({required this.bookId});

  @override
  String? get tag => bookId;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Obx(() {
        final list = controller.comments;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: controller.openComments,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Comments', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                    Text('${list.length} Reviews', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                  ],
                ),
              ),
            ),
            for (final c in list.take(3)) CommentTile(comment: c),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GestureDetector(
                onTap: controller.openComments,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    children: [
                      Expanded(child: Text('What do you think?', style: TextStyle(color: AppColors.textHint))),
                      Icon(Icons.send_rounded, color: AppColors.textHint, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _RelatedCard extends StatelessWidget {
  final List<BookModel> books;

  const _RelatedCard({required this.books});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text('You might like', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: BookGridTile.rowHeight(92),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: books.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => BookGridTile(book: books[i], width: 92, subtitle: ''),
            ),
          ),
        ],
      ),
    );
  }
}

/// Opening lines of chapter 1, so readers can sample before committing.
class _PreviewCard extends GetView<BookDetailController> {
  final BookModel book;
  final String bookId;

  @override
  String? get tag => bookId;

  const _PreviewCard({required this.book, required this.bookId});

  @override
  Widget build(BuildContext context) {
    final preview = MockData.chapterText(book, 1).split('\n\n').take(4).join('\n\n');
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chapter 1', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 10),
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.transparent],
              stops: [0.6, 1],
            ).createShader(r),
            blendMode: BlendMode.dstIn,
            child: Text(preview, style: const TextStyle(fontSize: 15, height: 1.6)),
          ),
          Center(
            child: TextButton.icon(
              onPressed: () => controller.read(1),
              icon: const Icon(Icons.keyboard_double_arrow_down_rounded, color: AppColors.primary),
              label: const Text('Read more', style: TextStyle(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends GetView<BookDetailController> {
  final String bookId;

  @override
  String? get tag => bookId;

  const _BottomBar({required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            children: [
              Obx(() => _BarIcon(
                    icon: controller.onShelf ? Icons.library_add_check_rounded : Icons.library_add_outlined,
                    label: controller.onShelf ? 'In Library' : 'Library',
                    active: controller.onShelf,
                    onTap: controller.toggleShelf,
                  )),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => GradientButton(
                      label: controller.hasProgress
                          ? 'CONTINUE · CH ${controller.resumeChapter}'
                          : 'READ',
                      onTap: controller.chapters.isEmpty ? null : () => controller.read(),
                    )),
              ),
              const SizedBox(width: 8),
              _BarIcon(
                icon: Icons.format_list_bulleted_rounded,
                label: 'Chapters',
                onTap: () => showChapterList(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _BarIcon({required this.icon, required this.label, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppColors.primary : AppColors.textPrimary),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
