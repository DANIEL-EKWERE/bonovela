import '../models/book_model.dart';
import '../models/chapter_model.dart';

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
/// this interface; [MockBookRepository] is the implementation for now.
abstract class BookRepository {
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
