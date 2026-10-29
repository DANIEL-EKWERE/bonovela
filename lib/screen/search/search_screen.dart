import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/book_tiles.dart';
import '../../widgets/common.dart';
import 'controller/search_controller.dart';

class SearchScreen extends GetView<BookSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeaderBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller.textController,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onChanged: controller.onChanged,
                        onSubmitted: controller.submit,
                        decoration: InputDecoration(
                          hintText: 'Search titles, authors, tags',
                          fillColor: Colors.white,
                          isDense: true,
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                          suffixIcon: Obx(() => controller.query.value.isEmpty
                              ? const SizedBox.shrink()
                              : IconButton(
                                  onPressed: controller.clear,
                                  icon: const Icon(Icons.cancel_rounded, color: AppColors.textHint, size: 18),
                                )),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: controller.openCategories,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          children: [
                            Icon(Icons.category_rounded, color: AppColors.primary, size: 18),
                            SizedBox(width: 4),
                            Text('Cats.', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() => controller.query.value.trim().isEmpty ? _Idle() : _Results()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Idle extends GetView<BookSearchController> {
  @override
  Widget build(BuildContext context) {
    Widget chip(String label) => ActionChip(
          label: Text(label, style: const TextStyle(fontSize: 13)),
          onPressed: () => controller.submit(label),
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.divider),
          shape: const StadiumBorder(),
        );

    return Obx(() => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            if (controller.history.isNotEmpty) ...[
              Row(
                children: [
                  const Text('Search history', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const Spacer(),
                  IconButton(
                    onPressed: controller.clearHistory,
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textHint),
                  ),
                ],
              ),
              Wrap(spacing: 8, runSpacing: 4, children: [for (final h in controller.history) chip(h)]),
              const SizedBox(height: 16),
            ],
            const Text('Popular searches', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 4, children: [for (final s in controller.suggestions) chip(s)]),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.blush, Colors.white],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Trending Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final (i, b) in controller.trending.indexed)
                    InkWell(
                      onTap: () => openBook(b),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            BookCover(book: b, width: 44, rank: i + 1, radius: 4),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  TagText(b.tags),
                                ],
                              ),
                            ),
                            Text(Fmt.compact(b.views),
                                style: const TextStyle(color: AppColors.star, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ));
  }
}

class _Results extends GetView<BookSearchController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSearching.value && controller.results.isEmpty) return const LoadingView();
      if (controller.results.isEmpty) {
        return EmptyState(
          icon: Icons.search_off_rounded,
          message: 'No results for "${controller.query.value}".\nTry a title, author or tag.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: controller.results.length,
        itemBuilder: (_, i) => BookListTile(book: controller.results[i], showRating: true),
      );
    });
  }
}
