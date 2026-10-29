class BookModel {
  final String id;
  final String title;
  final String author;
  final String synopsis;
  final String genre;
  final List<String> tags;
  final String coverUrl;
  final double rating;
  final int views;
  final int chapterCount;
  final int wordCount;
  final bool isCompleted;
  final bool isShort;
  final int ageRating;
  final DateTime updatedAt;

  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.synopsis,
    required this.genre,
    required this.tags,
    this.coverUrl = '',
    this.rating = 0,
    this.views = 0,
    this.chapterCount = 0,
    this.wordCount = 0,
    this.isCompleted = false,
    this.isShort = false,
    this.ageRating = 16,
    required this.updatedAt,
  });

  /// First tag, or the genre when the book has no tags.
  String get primaryTag => tags.isNotEmpty ? tags.first : genre;

  /// Picks a placeholder cover palette while [coverUrl] is empty.
  int get coverSeed => id.codeUnits.fold(0, (a, b) => a + b);

  factory BookModel.fromJson(Map<String, dynamic> j) => BookModel(
        id: j['id'].toString(),
        title: j['title']?.toString() ?? '',
        author: j['author']?.toString() ?? '',
        synopsis: j['synopsis']?.toString() ?? '',
        genre: j['genre']?.toString() ?? '',
        tags: (j['tags'] as List? ?? []).map((e) => e.toString()).toList(),
        coverUrl: j['cover_url']?.toString() ?? '',
        rating: (j['rating'] as num?)?.toDouble() ?? 0,
        views: (j['views'] as num?)?.toInt() ?? 0,
        chapterCount: (j['chapter_count'] as num?)?.toInt() ?? 0,
        wordCount: (j['word_count'] as num?)?.toInt() ?? 0,
        isCompleted: j['is_completed'] == true,
        isShort: j['is_short'] == true,
        ageRating: (j['age_rating'] as num?)?.toInt() ?? 16,
        updatedAt: DateTime.tryParse(j['updated_at']?.toString() ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'synopsis': synopsis,
        'genre': genre,
        'tags': tags,
        'cover_url': coverUrl,
        'rating': rating,
        'views': views,
        'chapter_count': chapterCount,
        'word_count': wordCount,
        'is_completed': isCompleted,
        'is_short': isShort,
        'age_rating': ageRating,
        'updated_at': updatedAt.toIso8601String(),
      };
}
