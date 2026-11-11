import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/repository/book_repository.dart';
import '../../../core/models/feed_section.dart';

class DiscoverController extends GetxController with GetSingleTickerProviderStateMixin {
  final _repo = Get.find<BookRepository>();

  final List<String> tabs = ['Discover', 'Free', 'New', ...AppConstants.genres];
  late final TabController tabController;

  /// Feed per tab, filled the first time a tab is opened.
  final RxMap<String, List<FeedSection>> feeds = <String, List<FeedSection>>{}.obs;
  final RxSet<String> loading = <String>{}.obs;

  /// Tabs whose last load failed (no connection, server down).
  final RxSet<String> failed = <String>{}.obs;

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
    failed.remove(tab);
    try {
      feeds[tab] = await _repo.getDiscoverFeed(tab);
    } catch (_) {
      failed.add(tab);
    } finally {
      loading.remove(tab);
    }
  }

  Future<void> refreshTab(String tab) => loadTab(tab, force: true);

  void openSearch() => Get.toNamed(AppRoutes.search);

  void openRewards() => Get.toNamed(AppRoutes.rewards);

  void openRanking() => Get.toNamed(AppRoutes.rank);
}
