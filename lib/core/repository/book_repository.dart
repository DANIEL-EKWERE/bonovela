import '../models/book_model.dart';
import '../models/chapter_model.dart';
import '../models/feed_section.dart';

enum RankType { bestsellers, risingStars, completed, hottestNew, readersChoice }

extension RankTypeLabel on RankType {
  String get label => switch (this) {
    RankType.bestsellers => 'Bestsellers',
    RankType.risingStars => 'Rising Stars',
    RankType.completed => 'Completed',
    RankType.hottestNew => 'Hottest New',
    RankType.readersChoice => "Readers' Choice",
  };
}

/// Everything the screens need for book content. Controllers only talk to
/// this interface: [ApiBookRepository] reads the backend, [MockBookRepository]
/// serves built-in sample data when no API_URL is set.
abstract class BookRepository {
  /// Sections of a Discover tab ('Discover', 'New' or a genre tab).
  Future<List<FeedSection>> getDiscoverFeed(String tab);

  /// Short Stories categories and their curated shelves.
  Future<List<ShortCollection>> getShortCollections();

  /// Full-length novels, optionally filtered by [genre].
  Future<List<BookModel>> getBooks({String? genre});

  /// Short stories, optionally filtered by [genre].
  Future<List<BookModel>> getShorts({String? genre});

  Future<BookModel?> getBook(String id);

  Future<List<BookModel>> getRanking(RankType type, {String? genre});

  Future<List<BookModel>> search(String query);

  /// Similar books for the detail page.
  Future<List<BookModel>> getRelated(BookModel book);

  /// Chapter list without content.
  Future<List<ChapterModel>> getChapters(String bookId);

  /// A single chapter with content. Locked chapters come back with empty
  /// content until unlocked.
  Future<ChapterModel> getChapter(String bookId, int number);

  /// Spends coins to unlock a chapter. Returns the unlocked chapter, or null
  /// when the balance is too low.
  Future<ChapterModel?> unlockChapter(String bookId, int number);
}
