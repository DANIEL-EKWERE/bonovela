import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/local_storage.dart';
import '../../../config/routes.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/book_model.dart';
import '../../../core/repository/book_repository.dart';

/// Named BookSearchController to avoid clashing with Flutter's SearchController.
class BookSearchController extends GetxController {
  final _repo = Get.find<BookRepository>();
  final _storage = Get.find<LocalStorage>();

  final textController = TextEditingController();
  final RxString query = ''.obs;
  final RxList<BookModel> results = <BookModel>[].obs;
  final RxList<BookModel> trending = <BookModel>[].obs;
  final RxList<String> history = <String>[].obs;
  final RxBool isSearching = false.obs;

  List<String> get suggestions => MockData.searchSuggestions;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    history.assignAll(_storage.searchHistory);
    _loadTrending();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    textController.dispose();
    super.onClose();
  }

  Future<void> _loadTrending() async {
    final books = await _repo.getRanking(RankType.bestsellers);
    trending.assignAll(books.take(8));
  }

  void onChanged(String value) {
    query.value = value;
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      results.clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _run(value));
  }

  /// Search from the keyboard action or a history/suggestion chip.
  void submit(String value) {
    final q = value.trim();
    if (q.isEmpty) return;
    textController.text = q;
    query.value = q;
    _storage.addSearch(q);
    history.assignAll(_storage.searchHistory);
    _run(q);
  }

  Future<void> _run(String q) async {
    isSearching.value = true;
    results.assignAll(await _repo.search(q));
    isSearching.value = false;
  }

  void openCategories() => Get.toNamed(AppRoutes.categories);

  void clear() {
    textController.clear();
    onChanged('');
  }

  void clearHistory() {
    _storage.clearSearchHistory();
    history.clear();
  }
}
