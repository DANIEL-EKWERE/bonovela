import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/book_model.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/book_tiles.dart';
import '../../widgets/common.dart';
import 'controller/short_controller.dart';

class ShortScreen extends GetView<ShortController> {
  const ShortScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: HeaderBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: SearchBarButton(onTap: controller.openSearch),
                ),
                TabBar(isScrollable: true, tabs: [for (final t in controller.tabs) Tab(text: t, height: 40)]),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) return const LoadingView();
                    return const TabBarView(children: [_HomeTab(), _SelectedTab(), _ArrivalsTab()]);
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends GetView<ShortController> {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: controller.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        children: [
          _Card(
            child: Column(
              children: [
                _SegmentBar(),
                Obx(() {
                  final books = controller.segmentBooks;
                  return Column(
                    children: [
                      for (var i = 0; i < books.length; i++) _RankedShortRow(book: books[i], rank: i + 1),
                    ],
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final c in controller.collections.take(2)) ...[
            _CollectionCard(collection: c, compact: true),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SegmentBar extends GetView<ShortController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.plum, AppColors.plumLight]),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Obx(() => Row(
            children: [
              for (var i = 0; i < controller.homeSegments.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.segment.value = i,
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                      decoration: BoxDecoration(
                        color: controller.segment.value == i ? AppColors.primary : Colors.transparent,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: Text(
                        controller.homeSegments[i],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: controller.segment.value == i ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}

class _RankedShortRow extends StatelessWidget {
  final BookModel book;
  final int rank;

  const _RankedShortRow({required this.book, required this.rank});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openBook(book),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '$rank  ',
                  style: TextStyle(
                    color: rank <= 3 ? AppColors.primary : AppColors.textHint,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                TextSpan(text: book.title),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(book: book, width: 44, badge: 'Short', radius: 4),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.synopsis,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      TagText(book.tags, max: 3),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedTab extends GetView<ShortController> {
  const _SelectedTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: [
        for (final c in controller.collections) ...[
          _CollectionCard(collection: c),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final ShortCollection collection;
  final bool compact;

  const _CollectionCard({required this.collection, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final books = compact ? collection.books.take(2) : collection.books.take(4);
    return _Card(
      child: Column(
        children: [
          Container(
            height: 72,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.plum, AppColors.primary]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '# ${collection.title}',
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Text(collection.subtitle, style: const TextStyle(color: AppColors.blushDeep, fontSize: 12)),
              ],
            ),
          ),
          for (final b in books) BookListTile(book: b, coverOnRight: true),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ArrivalsTab extends GetView<ShortController> {
  const _ArrivalsTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final groups = controller.arrivalsByDate;
      return ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        children: [
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final f in controller.arrivalFilters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: controller.arrivalFilter.value == f,
                      onSelected: (_) => controller.arrivalFilter.value = f,
                      showCheckmark: false,
                      selectedColor: AppColors.plum,
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        color: controller.arrivalFilter.value == f ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_checked_rounded, color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            _Card(
              child: Column(
                children: [
                  for (final b in entry.value) BookListTile(book: b, coverOnRight: true),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: child,
      );
}
