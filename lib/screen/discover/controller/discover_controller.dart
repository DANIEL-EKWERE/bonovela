import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/book_model.dart';
import '../../../core/repository/book_repository.dart';
import '../models/feed_section.dart';

class DiscoverController extends GetxController with GetSingleTickerProviderStateMixin {
  final _repo = Get.find<BookRepository>();

  final List<String> tabs = ['Discover', 'New', ...AppConstants.genres];
  late final TabController tabController;

  /// Feed per tab, filled the first time a tab is opened.
  final RxMap<String, List<FeedSection>> feeds = <String, List<FeedSection>>{}.obs;
  final RxSet<String> loading = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) loadTab(tabs[tabController.index]);
    });
    loadTab(tabs.first);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> loadTab(String tab, {bool force = false}) async {
    if (!force && (feeds.containsKey(tab) || loading.contains(tab))) return;
    loading.add(tab);
    try {
      feeds[tab] = await _buildFeed(tab);
    } finally {
      loading.remove(tab);
    }
  }

  Future<void> refreshTab(String tab) => loadTab(tab, force: true);

  void openSearch() => Get.toNamed(AppRoutes.search);

  void openRewards() => Get.toNamed(AppRoutes.rewards);

  void openRanking() => Get.toNamed(AppRoutes.rank);

  /// Each tab's feed is assembled from plain book lists.
  Future<List<FeedSection>> _buildFeed(String tab) async {
    switch (tab) {
      case 'Discover':
        final all = await _repo.getBooks();
        final popular = [...all]..sort((a, b) => b.views.compareTo(a.views));
        final fresh = [...all]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return [
          FeedSection(title: 'Top Picks', layout: FeedLayout.rankedColumns, books: popular.take(9).toList()),
          FeedSection(
            title: 'Readers Love These',
            layout: FeedLayout.coverRow,
            books: _shuffle(all, 1).take(8).toList(),
          ),
          FeedSection(title: 'Just Updated', layout: FeedLayout.detailList, books: fresh.take(6).toList()),
        ];
      case 'New':
        final all = await _repo.getBooks();
        final fresh = [...all]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return [
          FeedSection(title: 'Best Newcomers', layout: FeedLayout.hero, books: fresh.take(6).toList()),
          FeedSection(title: 'Trending', layout: FeedLayout.compactGrid, books: _shuffle(fresh, 2).take(6).toList()),
          FeedSection(title: 'Picks for You', layout: FeedLayout.ratedList, books: _shuffle(all, 3).take(5).toList()),
        ];
      default:
        final all = await _repo.getBooks(genre: tab);
        // Romance keeps its subgenres in their own sections.
        bool isSub(BookModel b) => b.tags.contains('Erotica') || b.tags.contains('MM Romance');
        final books = tab == 'Romance' ? all.where((b) => !isSub(b)).toList() : all;
        final fresh = [...books]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        final editors = [...books]..sort((a, b) => b.rating.compareTo(a.rating));
        final completed = books.where((b) => b.isCompleted).toList();
        final popular = [...books]..sort((a, b) => b.views.compareTo(a.views));
        if (tab == 'Romance') {
          List<BookModel> tagged(String t) =>
              all.where((b) => b.tags.contains(t)).toList()..sort((a, b) => b.views.compareTo(a.views));
          return [
            FeedSection(title: 'Recommended For You', layout: FeedLayout.compactGrid, books: popular.take(6).toList()),
            FeedSection(title: "Editor's Pick", layout: FeedLayout.hero, books: editors),
            if (completed.isNotEmpty) FeedSection(title: 'Completed', layout: FeedLayout.coverRow, books: completed),
            FeedSection(title: 'Love On Top', layout: FeedLayout.ratedList, books: _shuffle(books, 4)),
            FeedSection(title: 'Erotica', layout: FeedLayout.coverRow, books: tagged('Erotica')),
            FeedSection(title: 'MM Romance', layout: FeedLayout.detailList, books: tagged('MM Romance')),
          ];
        }
        return [
          FeedSection(title: 'New Arrival', layout: FeedLayout.compactGrid, books: fresh.take(6).toList()),
          FeedSection(title: "Editor's Pick", layout: FeedLayout.hero, books: editors),
          if (completed.isNotEmpty) FeedSection(title: 'Completed', layout: FeedLayout.coverRow, books: completed),
          FeedSection(title: 'Picks for You', layout: FeedLayout.ratedList, books: _shuffle(books, 4)),
        ];
    }
  }

  /// Stable reorder so mock sections don't all look identical.
  List<BookModel> _shuffle(List<BookModel> list, int seed) {
    final copy = [...list];
    copy.sort((a, b) => ((a.coverSeed * seed) % 17).compareTo((b.coverSeed * seed) % 17));
    return copy;
  }
}
