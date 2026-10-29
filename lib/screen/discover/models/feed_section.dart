import '../../../core/models/book_model.dart';

/// How a feed section lays out its books.
enum FeedLayout {
  /// Numbered rows in a horizontally paged two-column list.
  rankedColumns,

  /// Horizontal row of covers with title and tag.
  coverRow,

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
        books: (j['books'] as List? ?? [])
            .map((e) => BookModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  static String _camel(String snake) => snake.replaceAllMapped(
        RegExp(r'_([a-z])'),
        (m) => m.group(1)!.toUpperCase(),
      );
}
