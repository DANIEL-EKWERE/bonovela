class StoryDraft {
  final String id;
  final String title;
  final String genre;
  final String synopsis;
  final int chapters;
  final DateTime updatedAt;

  const StoryDraft({
    required this.id,
    required this.title,
    required this.genre,
    required this.synopsis,
    this.chapters = 0,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'genre': genre,
        'synopsis': synopsis,
        'chapters': chapters,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory StoryDraft.fromJson(Map j) => StoryDraft(
        id: j['id'].toString(),
        title: j['title']?.toString() ?? '',
        genre: j['genre']?.toString() ?? '',
        synopsis: j['synopsis']?.toString() ?? '',
        chapters: (j['chapters'] as num?)?.toInt() ?? 0,
        updatedAt: DateTime.tryParse(j['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      );
}
