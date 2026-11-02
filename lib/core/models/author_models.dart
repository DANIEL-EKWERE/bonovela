enum ChapterStatus { draft, published, trash }

/// A story the signed-in author is writing.
class AuthorStory {
  final String id;
  String title;

  /// Index into AppColors.coverPalettes; -1 until a cover is chosen.
  int coverIndex;

  /// Photo picked from the device (copied into app storage). Takes
  /// precedence over [coverIndex] when set.
  String coverPath;
  String language;
  String audience; // 'female' | 'male' | ''
  String rating; // '4+' | '12+' | '16+' | '18+' | ''
  String novelType; // 'Original' | 'Fan-fiction' | 'Translation'
  String genre;
  List<String> tags;
  String synopsis;
  List<String> contests;
  bool completed;
  bool signed;
  final DateTime createdAt;
  DateTime updatedAt;

  AuthorStory({
    required this.id,
    this.title = '',
    this.coverIndex = -1,
    this.coverPath = '',
    this.language = 'English',
    this.audience = '',
    this.rating = '',
    this.novelType = 'Original',
    this.genre = '',
    List<String>? tags,
    this.synopsis = '',
    List<String>? contests,
    this.completed = false,
    this.signed = false,
    required this.createdAt,
    required this.updatedAt,
  }) : tags = tags ?? [],
       contests = contests ?? [];

  String get displayTitle => title.isEmpty ? 'Unnamed' : title;

  static int wordCount(String text) => text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

  bool get hasCover => coverPath.isNotEmpty || coverIndex >= 0;

  /// Step 1 of Novel Information.
  bool get hasBasics => title.trim().isNotEmpty && hasCover && audience.isNotEmpty && rating.isNotEmpty;

  /// Step 2 of Novel Information.
  bool get hasDetails => genre.isNotEmpty && tags.isNotEmpty && synopsisOk;

  bool get synopsisOk {
    final w = wordCount(synopsis);
    return w >= 20 && w <= 300;
  }

  /// Ready to publish chapters.
  bool get isInfoComplete => hasBasics && hasDetails;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'coverIndex': coverIndex,
    'coverPath': coverPath,
    'language': language,
    'audience': audience,
    'rating': rating,
    'novelType': novelType,
    'genre': genre,
    'tags': tags,
    'synopsis': synopsis,
    'contests': contests,
    'completed': completed,
    'signed': signed,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory AuthorStory.fromJson(Map j) => AuthorStory(
    id: j['id'].toString(),
    title: j['title']?.toString() ?? '',
    coverIndex: (j['coverIndex'] as num?)?.toInt() ?? -1,
    coverPath: j['coverPath']?.toString() ?? '',
    language: j['language']?.toString() ?? 'English',
    audience: j['audience']?.toString() ?? '',
    rating: j['rating']?.toString() ?? '',
    novelType: j['novelType']?.toString() ?? 'Original',
    genre: j['genre']?.toString() ?? '',
    tags: (j['tags'] as List? ?? []).map((e) => e.toString()).toList(),
    synopsis: j['synopsis']?.toString() ?? '',
    contests: (j['contests'] as List? ?? []).map((e) => e.toString()).toList(),
    completed: j['completed'] == true,
    signed: j['signed'] == true,
    createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(j['updatedAt']?.toString() ?? '') ?? DateTime.now(),
  );
}

class AuthorChapter {
  final String id;
  final String storyId;
  int number;
  String title;
  String content;
  ChapterStatus status;

  /// Status before moving to trash, so Restore puts it back.
  ChapterStatus previousStatus;
  String note;
  DateTime updatedAt;
  DateTime? publishedAt;

  AuthorChapter({
    required this.id,
    required this.storyId,
    required this.number,
    this.title = '',
    this.content = '',
    this.status = ChapterStatus.draft,
    this.previousStatus = ChapterStatus.draft,
    this.note = '',
    required this.updatedAt,
    this.publishedAt,
  });

  int get words => AuthorStory.wordCount(content);

  String get label => number.toString().padLeft(3, '0');

  Map<String, dynamic> toJson() => {
    'id': id,
    'storyId': storyId,
    'number': number,
    'title': title,
    'content': content,
    'status': status.name,
    'previousStatus': previousStatus.name,
    'note': note,
    'updatedAt': updatedAt.toIso8601String(),
    'publishedAt': publishedAt?.toIso8601String(),
  };

  factory AuthorChapter.fromJson(Map j) => AuthorChapter(
    id: j['id'].toString(),
    storyId: j['storyId'].toString(),
    number: (j['number'] as num?)?.toInt() ?? 1,
    title: j['title']?.toString() ?? '',
    content: j['content']?.toString() ?? '',
    status: ChapterStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => ChapterStatus.draft),
    previousStatus: ChapterStatus.values.firstWhere(
      (s) => s.name == j['previousStatus'],
      orElse: () => ChapterStatus.draft,
    ),
    note: j['note']?.toString() ?? '',
    updatedAt: DateTime.tryParse(j['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    publishedAt: DateTime.tryParse(j['publishedAt']?.toString() ?? ''),
  );
}

/// A reader comment on one of the author's stories.
class AuthorComment {
  final String id;
  final String storyId;
  final String chapterTitle;
  final String user;
  final int stars;
  final String text;
  final DateTime date;
  final int likes;
  final List<String> replies;

  AuthorComment({
    required this.id,
    required this.storyId,
    this.chapterTitle = '',
    required this.user,
    required this.stars,
    required this.text,
    required this.date,
    this.likes = 0,
    List<String>? replies,
  }) : replies = replies ?? [];
}
