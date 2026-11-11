import 'package:get/get.dart';

import '../api/api_client.dart';
import '../models/book_model.dart';
import '../models/chapter_model.dart';
import '../models/feed_section.dart';
import '../services/account_service.dart';
import 'book_repository.dart';

/// [BookRepository] backed by the Bonovela API.
class ApiBookRepository implements BookRepository {
  final ApiClient _api;

  ApiBookRepository(this._api);

  /// List endpoints are paginated 20 per page; screens get up to this many.
  static const _maxPages = 5;

  static const _rankKeys = {
    RankType.bestsellers: 'bestsellers',
    RankType.risingStars: 'rising_stars',
    RankType.completed: 'completed',
    RankType.hottestNew: 'hottest_new',
    RankType.readersChoice: 'readers_choice',
  };

  List<BookModel> _books(Iterable<Map<String, dynamic>> rows) {
    // Follow needs the author's id; the app knows authors by name.
    final account = Get.isRegistered<AccountService>() ? Get.find<AccountService>() : null;
    for (final r in rows) {
      account?.rememberAuthor(r['author']?.toString() ?? '', r['author_id']?.toString() ?? '');
    }
    return rows.map(BookModel.fromJson).toList();
  }

  Future<List<BookModel>> _list(Map<String, String> query) async {
    final out = <BookModel>[];
    for (var page = 1; page <= _maxPages; page++) {
      final data = await _api.get('books/', {...query, 'page': '$page'});
      out.addAll(_books(ApiClient.rows(data)));
      if (data is! Map || data['next'] == null) break;
    }
    return out;
  }

  @override
  Future<List<FeedSection>> getDiscoverFeed(String tab) async {
    final data = await _api.get('books/discover/', {'tab': tab}) as List;
    return data.map((e) => FeedSection.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<List<ShortCollection>> getShortCollections() async {
    final data = await _api.get('shorts/collections/') as List;
    return data
        .map((e) => ShortCollection.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.sections.isNotEmpty)
        .toList();
  }

  @override
  Future<List<BookModel>> getBooks({String? genre}) => _list({'short': '0', 'genre': genre ?? ''});

  @override
  Future<List<BookModel>> getShorts({String? genre}) => _list({'short': '1', 'genre': genre ?? ''});

  @override
  Future<BookModel?> getBook(String id) async {
    try {
      return BookModel.fromJson(Map<String, dynamic>.from(await _api.get('books/$id/')));
    } on ApiException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<BookModel>> getRanking(RankType type, {String? genre}) async =>
      _books(ApiClient.rows(await _api.get('books/rankings/', {'type': _rankKeys[type]!, 'genre': genre ?? ''})));

  @override
  Future<List<BookModel>> search(String query) async => query.trim().isEmpty ? [] : _list({'q': query.trim()});

  @override
  Future<List<BookModel>> getRelated(BookModel book) async =>
      _books(ApiClient.rows(await _api.get('books/${book.id}/related/')));

  @override
  Future<List<ChapterModel>> getChapters(String bookId) async =>
      ApiClient.rows(await _api.get('books/$bookId/chapters/')).map(ChapterModel.fromJson).toList();

  @override
  Future<ChapterModel> getChapter(String bookId, int number) async =>
      ChapterModel.fromJson(Map<String, dynamic>.from(await _api.get('books/$bookId/chapters/$number/')));

  @override
  Future<ChapterModel?> unlockChapter(String bookId, int number) async {
    try {
      final chapter = ChapterModel.fromJson(
        Map<String, dynamic>.from(await _api.post('books/$bookId/chapters/$number/unlock/')),
      );
      if (Get.isRegistered<AccountService>()) Get.find<AccountService>().syncAccount(); // new balance
      return chapter;
    } on ApiException catch (e) {
      // 402: not enough coins; 401: not signed in to the backend yet.
      if (e.status == 402 || e.status == 401) return null;
      rethrow;
    }
  }
}
