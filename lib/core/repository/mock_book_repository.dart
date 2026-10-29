import 'package:get/get.dart';

import '../../config/local_storage.dart';
import '../constants/app_constants.dart';
import '../data/mock_data.dart';
import '../models/book_model.dart';
import '../models/chapter_model.dart';
import '../services/account_service.dart';
import 'book_repository.dart';

/// In-memory [BookRepository] backed by [MockData]. Short delays imitate
/// network latency so loading states get exercised.
class MockBookRepository implements BookRepository {
  static const _latency = Duration(milliseconds: 350);

  static const freeChapters = AppConstants.freeChapters;
  static const chapterPrice = AppConstants.chapterPrice;

  LocalStorage get _storage => Get.find<LocalStorage>();
  AccountService get _account => Get.find<AccountService>();

  List<BookModel> get _novels => MockData.books.where((b) => !b.isShort).toList();
  List<BookModel> get _shorts => MockData.books.where((b) => b.isShort).toList();

  List<BookModel> _byGenre(List<BookModel> list, String? genre) =>
      genre == null ? list : list.where((b) => b.genre == genre).toList();

  @override
  Future<List<BookModel>> getBooks({String? genre}) async {
    await Future.delayed(_latency);
    return _byGenre(_novels, genre);
  }

  @override
  Future<List<BookModel>> getShorts({String? genre}) async {
    await Future.delayed(_latency);
    return _byGenre(_shorts, genre);
  }

  @override
  Future<BookModel?> getBook(String id) async {
    await Future.delayed(_latency);
    return MockData.books.firstWhereOrNull((b) => b.id == id);
  }

  @override
  Future<List<BookModel>> getRanking(RankType type, {String? genre}) async {
    await Future.delayed(_latency);
    final list = _byGenre(_novels, genre);
    switch (type) {
      case RankType.bestsellers:
        list.sort((a, b) => b.views.compareTo(a.views));
      case RankType.risingStars:
        list.sort((a, b) => (b.views / b.chapterCount).compareTo(a.views / a.chapterCount));
      case RankType.completed:
        list.retainWhere((b) => b.isCompleted);
        list.sort((a, b) => b.views.compareTo(a.views));
      case RankType.hottestNew:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case RankType.readersChoice:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  @override
  Future<List<BookModel>> search(String query) async {
    await Future.delayed(_latency);
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return MockData.books
        .where((b) =>
            b.title.toLowerCase().contains(q) ||
            b.author.toLowerCase().contains(q) ||
            b.genre.toLowerCase().contains(q) ||
            b.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }

  @override
  Future<List<BookModel>> getRelated(BookModel book) async {
    await Future.delayed(_latency);
    return MockData.books
        .where((b) => b.id != book.id && b.genre == book.genre && b.isShort == book.isShort)
        .take(8)
        .toList();
  }

  /// Shorts: first 3 chapters free, the rest free with Bonovela Plus.
  static const freeShortChapters = 3;
  static const shortChapterPrice = 10;

  int _price(BookModel book) => book.isShort ? shortChapterPrice : chapterPrice;

  bool _isLocked(BookModel book, int number) {
    if (_storage.isUnlocked(book.id, number)) return false;
    if (book.isShort) return number > freeShortChapters && !_account.isPlus;
    return number > freeChapters;
  }

  ChapterModel _chapter(BookModel book, int number, {bool withContent = false}) {
    final locked = _isLocked(book, number);
    return ChapterModel(
      id: '${book.id}-$number',
      bookId: book.id,
      number: number,
      title: 'Chapter $number',
      isLocked: locked,
      coinPrice: _price(book),
      content: withContent && !locked ? MockData.chapterText(book, number) : '',
    );
  }

  @override
  Future<List<ChapterModel>> getChapters(String bookId) async {
    await Future.delayed(_latency);
    final book = MockData.books.firstWhere((b) => b.id == bookId);
    return List.generate(book.chapterCount, (i) => _chapter(book, i + 1));
  }

  @override
  Future<ChapterModel> getChapter(String bookId, int number) async {
    await Future.delayed(_latency);
    final book = MockData.books.firstWhere((b) => b.id == bookId);
    return _chapter(book, number, withContent: true);
  }

  @override
  Future<ChapterModel?> unlockChapter(String bookId, int number) async {
    await Future.delayed(_latency);
    final book = MockData.books.firstWhere((b) => b.id == bookId);
    final paid = _account.spend(
      _price(book),
      title: '${book.title} · Chapter $number',
      bookId: bookId,
      chapter: number,
    );
    if (!paid) return null;
    _storage.markUnlocked(bookId, number);
    return getChapter(bookId, number);
  }
}
