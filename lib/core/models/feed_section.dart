import 'book_model.dart';

/// How a feed section lays out its books.
enum FeedLayout {
  /// Grid of covers, four per row, with title and tag underneath.
  coverGrid,

  /// Horizontal row of covers with title and tag.
  coverRow,

  /// Pages of three rows (cover, title, blurb), swiped sideways.
  pagedList,

  /// Vertical list: cover, title, synopsis, tags, views.
  detailList,

  /// One featured book with its blurb, then a cover row of the rest.
  hero,

  /// Two-column grid of compact rows with rank numbers.
  compactGrid,

  /// Vertical list with star rating and view count.
  ratedList,
}

class FeedSection {
  final String title;
  final FeedLayout layout;
  final List<BookModel> books;

  const FeedSection({required this.title, required this.layout, required this.books});

  /// Server shape: {"title": "...", "layout": "cover_row", "books": [...]}
  factory FeedSection.fromJson(Map<String, dynamic> j) => FeedSection(
    title: j['title']?.toString() ?? '',
    layout: FeedLayout.values.firstWhere(
      (l) => l.name == _camel(j['layout']?.toString() ?? ''),
      orElse: () => FeedLayout.coverRow,
    ),
    books: (j['books'] as List? ?? []).map((e) => BookModel.fromJson(Map<String, dynamic>.from(e))).toList(),
  );

  static String _camel(String snake) => snake.replaceAllMapped(RegExp(r'_([a-z])'), (m) => m.group(1)!.toUpperCase());
}

/// A Short Stories category ("Love at First Sight", …) and its shelves.
class ShortCollection {
  final String title;
  final List<FeedSection> sections;

  const ShortCollection({required this.title, required this.sections});

  List<BookModel> get books => [for (final s in sections) ...s.books];

  factory ShortCollection.fromJson(Map<String, dynamic> j) => ShortCollection(
    title: j['title']?.toString() ?? '',
    sections: (j['sections'] as List? ?? []).map((e) => FeedSection.fromJson(Map<String, dynamic>.from(e))).toList(),
  );
}
