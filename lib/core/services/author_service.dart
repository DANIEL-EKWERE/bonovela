import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../config/local_storage.dart';
import '../models/author_models.dart';

/// Mock author backend: the signed-in author's stories, chapters, comment
/// replies. Persisted on the device through [LocalStorage].
class AuthorService extends GetxService {
  final _s = Get.find<LocalStorage>();

  static const _kStories = 'author_stories';
  static const _kChapters = 'author_chapters';
  static const _kReplies = 'author_replies';

  final RxList<AuthorStory> stories = <AuthorStory>[].obs;
  final RxList<AuthorChapter> chapters = <AuthorChapter>[].obs;

  /// commentId → the author's replies.
  final RxMap<String, List<String>> replies = <String, List<String>>{}.obs;

  AuthorService init() {
    stories.assignAll((_s.read<List>(_kStories) ?? []).whereType<Map>().map(AuthorStory.fromJson));
    chapters.assignAll((_s.read<List>(_kChapters) ?? []).whereType<Map>().map(AuthorChapter.fromJson));
    final r = _s.read<Map>(_kReplies) ?? {};
    replies.assignAll(r.map((k, v) => MapEntry(k.toString(), (v as List).map((e) => e.toString()).toList())));
    return this;
  }

  void _save() {
    _s.write(_kStories, stories.map((e) => e.toJson()).toList());
    _s.write(_kChapters, chapters.map((e) => e.toJson()).toList());
    _s.write(_kReplies, replies);
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  // ── Stories ────────────────────────────────────────────────────────────────
  AuthorStory? story(String id) => stories.firstWhereOrNull((s) => s.id == id);

  AuthorStory newStory() {
    final now = DateTime.now();
    return AuthorStory(id: _id(), createdAt: now, updatedAt: now);
  }

  /// Inserts or replaces.
  void saveStory(AuthorStory story) {
    story.updatedAt = DateTime.now();
    final i = stories.indexWhere((s) => s.id == story.id);
    i >= 0 ? stories[i] = story : stories.insert(0, story);
    stories.refresh();
    _save();
  }

  /// Copies a picked image into app storage (picker files live in a temp
  /// folder the OS may clear) and returns the new path.
  Future<String> importCover(String sourcePath, String storyId) async {
    final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/covers');
    await dir.create(recursive: true);
    final ext = sourcePath.contains('.') ? sourcePath.substring(sourcePath.lastIndexOf('.')) : '.jpg';
    final target = '${dir.path}/${storyId}_${DateTime.now().millisecondsSinceEpoch}$ext';
    await File(sourcePath).copy(target);
    return target;
  }

  /// Removes a cover file we own; ignores anything already gone.
  Future<void> deleteCoverFile(String path) async {
    if (path.isEmpty) return;
    try {
      await File(path).delete();
    } catch (_) {}
  }

  void deleteStory(String id) {
    final cover = story(id)?.coverPath ?? '';
    deleteCoverFile(cover);
    stories.removeWhere((s) => s.id == id);
    chapters.removeWhere((c) => c.storyId == id);
    _save();
  }

  // ── Chapters ───────────────────────────────────────────────────────────────
  List<AuthorChapter> chaptersOf(String storyId, [ChapterStatus? status]) =>
      chapters.where((c) => c.storyId == storyId && (status == null || c.status == status)).toList()
        ..sort((a, b) => b.number.compareTo(a.number));

  AuthorChapter? chapter(String id) => chapters.firstWhereOrNull((c) => c.id == id);

  /// A fresh draft numbered after the story's last chapter.
  AuthorChapter newChapter(String storyId) {
    final numbers = chapters.where((c) => c.storyId == storyId).map((c) => c.number);
    final next = numbers.isEmpty ? 1 : numbers.reduce((a, b) => a > b ? a : b) + 1;
    return AuthorChapter(id: _id(), storyId: storyId, number: next, updatedAt: DateTime.now());
  }

  void saveChapter(AuthorChapter c) {
    c.updatedAt = DateTime.now();
    final i = chapters.indexWhere((x) => x.id == c.id);
    i >= 0 ? chapters[i] = c : chapters.add(c);
    chapters.refresh();
    story(c.storyId)?.updatedAt = DateTime.now();
    _save();
  }

  void publishChapter(AuthorChapter c) {
    c.status = ChapterStatus.published;
    c.publishedAt = DateTime.now();
    saveChapter(c);
  }

  void trashChapter(AuthorChapter c) {
    c.previousStatus = c.status;
    c.status = ChapterStatus.trash;
    saveChapter(c);
  }

  void restoreChapter(AuthorChapter c) {
    c.status = c.previousStatus == ChapterStatus.trash ? ChapterStatus.draft : c.previousStatus;
    saveChapter(c);
  }

  void deleteChapterForever(AuthorChapter c) {
    chapters.removeWhere((x) => x.id == c.id);
    _save();
  }

  // ── Stats ──────────────────────────────────────────────────────────────────
  List<AuthorChapter> published(String storyId) => chaptersOf(storyId, ChapterStatus.published);

  int totalWords(String storyId) => published(storyId).fold(0, (s, c) => s + c.words);

  /// Words published per day (yyyy-mm-dd → words) for the update calendar.
  Map<String, int> wordsByDay(String storyId) {
    final out = <String, int>{};
    for (final c in published(storyId)) {
      final d = c.publishedAt ?? c.updatedAt;
      final key = '${d.year}-${d.month}-${d.day}';
      out[key] = (out[key] ?? 0) + c.words;
    }
    return out;
  }

  // ── Comments (mock readers) ────────────────────────────────────────────────
  static const _readers = ['Nasadie', 'Honey Queen', 'Ada', 'Chioma', 'Grace', 'Tolu', 'Jess'];
  static const _texts = [
    'so interesting',
    'The way he shows his concern without outright saying it is amazing',
    'Please update soon, I need the next chapter!',
    'She is so brave, I love her character',
    'This chapter had me in tears 😭',
  ];

  /// Readers start commenting once a story has published chapters.
  List<AuthorComment> commentsFor(AuthorStory story) {
    final pub = published(story.id);
    if (pub.isEmpty) return [];
    final seed = story.id.codeUnits.fold(0, (a, b) => a + b);
    final count = (pub.length * 2).clamp(1, 12);
    return List.generate(count, (i) {
      final k = seed + i * 7;
      final ch = pub[i % pub.length];
      final id = '${story.id}-cm$i';
      return AuthorComment(
        id: id,
        storyId: story.id,
        chapterTitle: ch.title.isEmpty ? 'Chapter ${ch.number}' : ch.title,
        user: _readers[k % _readers.length],
        stars: 4 + (k % 2),
        text: _texts[k % _texts.length],
        date: (ch.publishedAt ?? ch.updatedAt).add(Duration(hours: 2 + i * 5)),
        likes: k % 9,
        replies: replies[id] ?? [],
      );
    });
  }

  void reply(String commentId, String text) {
    replies[commentId] = [...(replies[commentId] ?? []), text];
    _save();
  }
}
