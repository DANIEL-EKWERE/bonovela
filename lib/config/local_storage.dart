import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Read progress for one book.
class ReadProgress {
  final String bookId;
  final int chapter;
  final DateTime readAt;

  const ReadProgress(this.bookId, this.chapter, this.readAt);

  Map<String, dynamic> toJson() =>
      {'bookId': bookId, 'chapter': chapter, 'readAt': readAt.toIso8601String()};

  factory ReadProgress.fromJson(Map j) => ReadProgress(
        j['bookId'].toString(),
        (j['chapter'] as num?)?.toInt() ?? 1,
        DateTime.tryParse(j['readAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

/// On-device storage: shelf, reading history, unlocked chapters, search
/// history and generic key/value prefs. Account and wallet state lives in
/// AccountService, which persists through [read]/[write].
class LocalStorage extends GetxService {
  final _box = GetStorage();

  static const _kShelf = 'shelf';
  static const _kHistory = 'history';
  static const _kSearchHistory = 'search_history';
  static const _kUnlocked = 'unlocked';

  /// Shelf book ids, newest first. Observed by Library and Book detail.
  final RxList<String> shelf = <String>[].obs;

  /// Reading history, newest first.
  final RxList<ReadProgress> history = <ReadProgress>[].obs;

  Future<LocalStorage> init() async {
    await GetStorage.init();
    shelf.assignAll((_box.read<List>(_kShelf) ?? []).map((e) => e.toString()));
    history.assignAll(
      (_box.read<List>(_kHistory) ?? []).whereType<Map>().map(ReadProgress.fromJson),
    );
    return this;
  }

  // ── Shelf ──────────────────────────────────────────────────────────────────
  bool isOnShelf(String bookId) => shelf.contains(bookId);

  void toggleShelf(String bookId) {
    isOnShelf(bookId) ? shelf.remove(bookId) : shelf.insert(0, bookId);
    _box.write(_kShelf, shelf.toList());
  }

  void addToShelf(String bookId) {
    if (!isOnShelf(bookId)) toggleShelf(bookId);
  }

  // ── History ────────────────────────────────────────────────────────────────
  ReadProgress? progressFor(String bookId) =>
      history.firstWhereOrNull((p) => p.bookId == bookId);

  void saveProgress(String bookId, int chapter) {
    history.removeWhere((p) => p.bookId == bookId);
    history.insert(0, ReadProgress(bookId, chapter, DateTime.now()));
    if (history.length > 100) history.removeRange(100, history.length);
    _box.write(_kHistory, history.map((p) => p.toJson()).toList());
  }

  void clearHistory() {
    history.clear();
    _box.remove(_kHistory);
  }

  // ── Search history ─────────────────────────────────────────────────────────
  List<String> get searchHistory =>
      (_box.read<List>(_kSearchHistory) ?? []).map((e) => e.toString()).toList();

  void addSearch(String query) {
    final list = searchHistory..remove(query)..insert(0, query);
    _box.write(_kSearchHistory, list.take(10).toList());
  }

  void clearSearchHistory() => _box.remove(_kSearchHistory);

  // ── Unlocked chapters ──────────────────────────────────────────────────────
  bool isUnlocked(String bookId, int chapter) =>
      (_box.read<List>(_kUnlocked) ?? []).contains('$bookId:$chapter');

  void markUnlocked(String bookId, int chapter) {
    final list = (_box.read<List>(_kUnlocked) ?? []).toList()..add('$bookId:$chapter');
    _box.write(_kUnlocked, list);
  }

  // ── Generic prefs ──────────────────────────────────────────────────────────
  T? read<T>(String key) => _box.read<T>(key);
  void write(String key, dynamic value) => _box.write(key, value);
  void remove(String key) => _box.remove(key);
}
