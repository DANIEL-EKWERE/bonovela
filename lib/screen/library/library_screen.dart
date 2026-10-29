import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/book_model.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/book_tiles.dart' as tiles;
import '../../widgets/common.dart';
import '../main/controller/main_controller.dart';
import 'controller/library_controller.dart';

class LibraryScreen extends GetView<LibraryController> {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: HeaderBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) return const LoadingView();
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: controller.reload,
                    child: CustomScrollView(
                      slivers: [
                        if (controller.banner.isNotEmpty)
                          SliverToBoxAdapter(child: _Banner()),
                        if (controller.tabIndex.value == 0) SliverToBoxAdapter(child: _FilterBar()),
                        controller.tabIndex.value == 0 ? _ShelfGrid() : _ViewedList(),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends GetView<LibraryController> {
  @override
  Widget build(BuildContext context) {
    Widget tab(String label, int index) => GestureDetector(
          onTap: () => controller.tabIndex.value = index,
          child: Obx(() {
            final active = controller.tabIndex.value == index;
            return Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: active ? 19 : 17,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      color: active ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 18,
                    height: 3,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            );
          }),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
      child: Row(
        children: [
          tab('Reading', 0),
          tab('Viewed', 1),
          const Spacer(),
          IconButton(
            onPressed: controller.openRewards,
            icon: const Icon(Icons.card_giftcard_rounded, color: AppColors.primary),
          ),
          Obx(() => controller.tabIndex.value == 1 && controller.viewedBooks.isNotEmpty
              ? TextButton(
                  onPressed: controller.clearHistory,
                  child: const Text('Clear', style: TextStyle(color: AppColors.textSecondary)),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

/// Auto-sized carousel of top-rated books.
class _Banner extends GetView<LibraryController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      height: 104,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: controller.banner.length,
              onPageChanged: (i) => controller.bannerIndex.value = i,
              itemBuilder: (_, i) {
                final book = controller.banner[i];
                return GestureDetector(
                  onTap: () => tiles.openBook(book),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Row(
                      children: [
                        BookCover(book: book, width: 54, showRating: true, radius: 4),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                book.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.synopsis,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < controller.banner.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                      width: i == controller.bannerIndex.value ? 14 : 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: i == controller.bannerIndex.value ? AppColors.plum : AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              )),
        ],
      ),
    );
  }
}

class _FilterBar extends GetView<LibraryController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          for (final f in LibraryController.filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Obx(() {
                final on = controller.filter.value == f;
                return GestureDetector(
                  onTap: () => controller.filter.value = f,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: on ? AppColors.blush : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 13,
                        color: on ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }),
            ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: controller.openSearch,
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, size: 18, color: AppColors.textHint),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text('Search...',
                          overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShelfGrid extends GetView<LibraryController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
    final books = controller.filteredShelf;
    if (books.isEmpty && controller.shelfBooks.isNotEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.filter_alt_off_rounded,
          message: 'No ${controller.filter.value.toLowerCase()} on your shelf yet.',
        ),
      );
    }
    if (books.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.menu_book_rounded,
          message: controller.shelfBooks.isEmpty
              ? 'Your shelf is empty.\nAdd stories you love and they\'ll show up here.'
              : 'No ${controller.filter.value.toLowerCase()} on your shelf yet.',
          actionLabel: 'Discover stories',
          onAction: () => Get.find<MainController>().changeTab(1),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: LayoutBuilder(builder: (context, c) {
            final width = (c.maxWidth - 2 * 14) / 3;
            return Wrap(
              spacing: 14,
              runSpacing: 16,
              children: [for (final b in books) _ShelfTile(book: b, width: width)],
            );
          }),
        ),
      ),
    );
    });
  }
}

class _ShelfTile extends GetView<LibraryController> {
  final BookModel book;
  final double width;

  const _ShelfTile({required this.book, required this.width});

  @override
  Widget build(BuildContext context) {
    final readAt = controller.lastReadAt(book.id);
    return GestureDetector(
      onTap: () => controller.openBook(book),
      onLongPress: () => _confirmRemove(context),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(
              book: book,
              width: width,
              badge: controller.isRecommended(book) ? 'Recommended' : (book.isShort ? 'Short' : null),
            ),
            const SizedBox(height: 6),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.25),
            ),
            const SizedBox(height: 2),
            Text(
              readAt != null ? Fmt.ago(readAt) : 'Not started',
              style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Book details'),
              onTap: () {
                Get.back();
                tiles.openBook(book);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: const Text('Remove from library', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Get.back();
                controller.removeFromShelf(book);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewedList extends GetView<LibraryController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
    final books = controller.viewedBooks;
    if (books.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(icon: Icons.history_rounded, message: 'Books you open will appear here.'),
      );
    }
    return SliverList.builder(
      itemCount: books.length,
      itemBuilder: (_, i) {
        final book = books[i];
        final chapter = controller.lastChapter(book.id) ?? 1;
        final readAt = controller.lastReadAt(book.id);
        return InkWell(
          onTap: () => controller.openBook(book),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                BookCover(book: book, width: 56),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Read to Chapter $chapter / ${book.chapterCount}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      if (readAt != null)
                        Text(Fmt.ago(readAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
              ],
            ),
          ),
        );
      },
    );
    });
  }
}
