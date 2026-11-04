import 'book_model.dart';

/// Original series filmed for the app, or a drama adapted from a novel.
enum DramaKind { drama, adapted }

class DramaModel {
  final String id;
  final String title;
  final String synopsis;
  final DramaKind kind;
  final String genre;
  final List<String> tags;
  final String coverUrl;
  final int plays;
  final int episodeCount;

  /// Novel this drama was adapted from (when [kind] is adapted).
  final String? bookId;
  final bool isCompleted;
  final DateTime releasedAt;

  const DramaModel({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.kind,
    required this.genre,
    this.tags = const [],
    this.coverUrl = '',
    this.plays = 0,
    this.episodeCount = 60,
    this.bookId,
    this.isCompleted = true,
    required this.releasedAt,
  });

  bool get isAdapted => kind == DramaKind.adapted;
  String get kindLabel => isAdapted ? 'Adapted' : 'Drama';

  /// Lets [BookCover] draw the same placeholder art used for novels.
  BookModel get asBook => BookModel(
    id: id,
    title: title,
    author: kindLabel,
    synopsis: synopsis,
    genre: genre,
    tags: tags,
    coverUrl: coverUrl,
    updatedAt: releasedAt,
  );

  /// Mock running time, 60–110 seconds, stable per episode.
  int episodeSeconds(int episode) => 60 + (id.codeUnits.fold(0, (a, b) => a + b) * 31 + episode * 7919) % 51;

  factory DramaModel.fromJson(Map<String, dynamic> j) => DramaModel(
    id: j['id'].toString(),
    title: j['title']?.toString() ?? '',
    synopsis: j['synopsis']?.toString() ?? '',
    kind: j['kind'] == 'adapted' ? DramaKind.adapted : DramaKind.drama,
    genre: j['genre']?.toString() ?? '',
    tags: (j['tags'] as List? ?? []).map((e) => e.toString()).toList(),
    coverUrl: j['cover_url']?.toString() ?? '',
    plays: (j['plays'] as num?)?.toInt() ?? 0,
    episodeCount: (j['episode_count'] as num?)?.toInt() ?? 0,
    bookId: j['book_id']?.toString(),
    isCompleted: j['is_completed'] == true,
    releasedAt: DateTime.tryParse(j['released_at']?.toString() ?? '') ?? DateTime.now(),
  );
}
