import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../config/local_storage.dart';
import '../../widgets/ui_kit.dart';
import '../api/api_client.dart';
import '../constants/app_constants.dart';
import '../data/author_data.dart';
import '../models/author_models.dart';
import '../models/contract_application.dart';
import 'account_service.dart';

/// The signed-in author's stories, chapters and comments.
///
/// Screens read and change the local lists, which stay on the device so they
/// load instantly. With a backend every change is also sent to
/// /api/author/… (in order, one at a time) and [sync] pulls the server's
/// copy, matched by remote id. Without a backend (sample-data builds) the
/// local lists are all there is.
class AuthorService extends GetxService {
  final _s = Get.find<LocalStorage>();

  static const _kStories = 'author_stories';
  static const _kChapters = 'author_chapters';
  static const _kReplies = 'author_replies';
  static const _kOwner = 'author_owner';

  final RxList<AuthorStory> stories = <AuthorStory>[].obs;
  final RxList<AuthorChapter> chapters = <AuthorChapter>[].obs;

  /// commentId → the author's replies.
  final RxMap<String, List<String>> replies = <String, List<String>>{}.obs;

  /// storyId → reader comments from the server.
  final RxMap<String, List<AuthorComment>> _comments = <String, List<AuthorComment>>{}.obs;
  final RxBool syncing = false.obs;

  ApiClient? get _api => Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null;
  AccountService get _account => Get.find<AccountService>();

  /// The backend is in use and the user is a signed-in author.
  bool get _online => _api != null && _api!.signedIn && (_account.user.value?.isAuthor ?? false);

  AuthorService init() {
    stories.assignAll((_s.read<List>(_kStories) ?? []).whereType<Map>().map(AuthorStory.fromJson));
    chapters.assignAll((_s.read<List>(_kChapters) ?? []).whereType<Map>().map(AuthorChapter.fromJson));
    final r = _s.read<Map>(_kReplies) ?? {};
    replies.assignAll(r.map((k, v) => MapEntry(k.toString(), (v as List).map((e) => e.toString()).toList())));
    if (_api != null) {
      _onUser();
      ever(_account.user, (_) => _onUser());
    }
    return this;
  }

  /// A different account signed in (or out): its books aren't this one's.
  void _onUser() {
    final u = _account.user.value;
    final owner = u?.email ?? '';
    if (owner != (_s.read<String>(_kOwner) ?? owner)) {
      stories.clear();
      chapters.clear();
      replies.clear();
      _comments.clear();
    }
    _s.write(_kOwner, owner);
    _save();
    if (u?.isAuthor ?? false) sync();
  }

  void _save() {
    _s.write(_kStories, stories.map((e) => e.toJson()).toList());
    _s.write(_kChapters, chapters.map((e) => e.toJson()).toList());
    _s.write(_kReplies, replies);
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  // ── Server queue ───────────────────────────────────────────────────────────
  Future<void> _queue = Future.value();

  /// Runs server calls one after another (a chapter needs its story first).
  /// Failures are shown, never thrown at the screen.
  Future<void> _remote(Future<void> Function(ApiClient api) call) {
    if (!_online) return Future.value();
    final api = _api!;
    return _queue = _queue.then((_) async {
      try {
        await call(api);
      } on ApiException catch (e) {
        toast("Couldn't save to Bonovela", e.message);
      } catch (_) {
        toast("Couldn't reach Bonovela", "Your changes are kept on this phone and sent when you're back online.");
      }
    });
  }

  // ── Pull from the server ───────────────────────────────────────────────────
  /// Brings the lists in line with the server and sends anything not yet sent.
  Future<void> sync() async {
    if (!_online || syncing.value) return;
    syncing.value = true;
    try {
      final api = _api!;
      final rows = (await api.get('author/stories/') as List).cast<Map>();
      final seen = <String>{};
      for (final row in rows) {
        final rid = row['id'].toString();
        seen.add(rid);
        final local = stories.firstWhereOrNull((s) => s.remoteId == rid);
        final story = local ?? AuthorStory(id: 'r$rid', createdAt: DateTime.now(), updatedAt: DateTime.now());
        _storyFromApi(story, row);
        if (local == null) stories.add(story);
      }
      stories.removeWhere((s) => s.remoteId.isNotEmpty && !seen.contains(s.remoteId));
      chapters.removeWhere((c) => story(c.storyId) == null);
      for (final s in stories.where((s) => s.remoteId.isNotEmpty).toList()) {
        await _pullChapters(api, s);
      }
      stories.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      stories.refresh();
      chapters.refresh();
      _save();
      // Written offline or before signing in: send now.
      for (final s in stories.where((s) => s.remoteId.isEmpty).toList()) {
        _pushStory(s);
      }
      for (final c in chapters.where((c) => c.remoteId.isEmpty).toList()) {
        _pushChapter(c);
      }
    } catch (_) {
      // Offline: keep what's on the phone.
    } finally {
      syncing.value = false;
    }
  }

  Future<void> _pullChapters(ApiClient api, AuthorStory s) async {
    final rows = (await api.get('author/stories/${s.remoteId}/chapters/') as List).cast<Map>();
    final seen = <String>{};
    for (final row in rows) {
      final rid = row['id'].toString();
      seen.add(rid);
      final local = chapters.firstWhereOrNull((c) => c.remoteId == rid);
      final ch = local ?? AuthorChapter(id: 'r$rid', storyId: s.id, number: 1, updatedAt: DateTime.now());
      _chapterFromApi(ch, row);
      if (local == null) chapters.add(ch);
    }
    chapters.removeWhere((c) => c.storyId == s.id && c.remoteId.isNotEmpty && !seen.contains(c.remoteId));
  }

  static const _types = {'original': 'Original', 'fan_fiction': 'Fan-fiction', 'translation': 'Translation'};

  void _storyFromApi(AuthorStory s, Map j) {
    s
      ..remoteId = j['id'].toString()
      ..title = j['title']?.toString() ?? ''
      ..coverIndex = (j['cover_index'] as num?)?.toInt() ?? -1
      ..coverUrl = j['cover']?.toString() ?? ''
      ..language = j['language']?.toString() ?? 'English'
      ..audience = j['audience']?.toString() ?? ''
      ..rating = j['content_rating']?.toString() ?? ''
      ..novelType = _types[j['novel_type']] ?? 'Original'
      ..genre = j['genre']?.toString() ?? ''
      ..tags = [for (final t in (j['tags'] as List? ?? [])) t.toString()]
      ..synopsis = j['synopsis']?.toString() ?? ''
      ..isShort = j['is_short'] == true
      ..completed = j['status'] == 'completed'
      ..signed = j['is_signed'] == true
      ..applicationStatus = j['application_status']?.toString() ?? ''
      ..views = (j['views'] as num?)?.toInt() ?? 0
      ..updatedAt = DateTime.tryParse(j['updated_at']?.toString() ?? '') ?? s.updatedAt;
  }

  static ChapterStatus _status(String? s) => switch (s) {
    'published' => ChapterStatus.published,
    'trash' || 'removed' => ChapterStatus.trash,
    _ => ChapterStatus.draft,
  };

  void _chapterFromApi(AuthorChapter c, Map j) {
    c
      ..remoteId = j['id'].toString()
      ..number = (j['number'] as num?)?.toInt() ?? c.number
      ..title = j['title']?.toString() ?? ''
      ..content = j['content']?.toString() ?? ''
      ..note = j['note']?.toString() ?? ''
      ..status = _status(j['status']?.toString())
      ..publishedAt = DateTime.tryParse(j['published_at']?.toString() ?? '')
      ..updatedAt = DateTime.tryParse(j['updated_at']?.toString() ?? '') ?? c.updatedAt;
  }

  // ── Push to the server ─────────────────────────────────────────────────────
  Map<String, dynamic> _storyToApi(AuthorStory s) => {
    'title': s.title,
    'language': s.language,
    'audience': s.audience,
    'content_rating': s.rating,
    'novel_type': _types.keys.firstWhere((k) => _types[k] == s.novelType, orElse: () => 'original'),
    'genre': s.genre.isEmpty ? null : s.genre,
    'tags': s.tags,
    'synopsis': s.synopsis,
    'is_short': s.isShort,
    'cover_index': s.coverPath.isEmpty ? s.coverIndex : -1,
    if (s.completed) 'status': 'completed',
  };

  void _pushStory(AuthorStory s) => _remote((api) async {
    final body = _storyToApi(s);
    final Map row = s.remoteId.isEmpty
        ? await api.post('author/stories/', body) as Map
        : await api.patch('author/stories/${s.remoteId}/', body) as Map;
    s.remoteId = row['id'].toString();
    if (s.coverPath.isNotEmpty && s.coverPath != s.uploadedCover && File(s.coverPath).existsSync()) {
      final withCover = await api.upload('author/stories/${s.remoteId}/', {}, {'cover': s.coverPath}, method: 'PATCH');
      s.uploadedCover = s.coverPath;
      _storyFromApi(s, withCover as Map);
    } else {
      _storyFromApi(s, row);
    }
    stories.refresh();
    _save();
  });

  /// Saves the chapter's text, then [then] (publish / trash / restore).
  void _pushChapter(AuthorChapter c, {String? then}) => _remote((api) async {
    final s = story(c.storyId);
    if (s == null || s.remoteId.isEmpty) return; // its story will send it
    final base = 'author/stories/${s.remoteId}/chapters/';
    final body = {'title': c.title, 'content': c.content, 'note': c.note};
    final Map row = c.remoteId.isEmpty
        ? await api.post(base, body) as Map
        : await api.patch('$base${c.remoteId}/', body) as Map;
    c.remoteId = row['id'].toString();
    if (then != null) {
      try {
        _chapterFromApi(c, await api.post('$base${c.remoteId}/$then/') as Map);
      } on ApiException {
        c.status = ChapterStatus.draft; // the server said no; show it as a draft
        rethrow;
      } finally {
        chapters.refresh();
        _save();
      }
    }
    _save();
  });

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
    _pushStory(story);
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
    final s = story(id);
    deleteCoverFile(s?.coverPath ?? '');
    stories.removeWhere((s) => s.id == id);
    chapters.removeWhere((c) => c.storyId == id);
    _save();
    final rid = s?.remoteId ?? '';
    if (rid.isNotEmpty) _remote((api) => api.delete('author/stories/$rid/'));
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

  void _keep(AuthorChapter c) {
    c.updatedAt = DateTime.now();
    final i = chapters.indexWhere((x) => x.id == c.id);
    i >= 0 ? chapters[i] = c : chapters.add(c);
    chapters.refresh();
    story(c.storyId)?.updatedAt = DateTime.now();
    _save();
  }

  void saveChapter(AuthorChapter c) {
    _keep(c);
    _pushChapter(c);
  }

  /// Returns why the chapter can't be published, or null once it is.
  String? publishChapter(AuthorChapter c) {
    final error = AuthorChapter.lengthError(c.words);
    if (error != null) return error;
    c.status = ChapterStatus.published;
    c.publishedAt = DateTime.now();
    _keep(c);
    _pushChapter(c, then: 'publish');
    return null;
  }

  void trashChapter(AuthorChapter c) {
    c.previousStatus = c.status;
    c.status = ChapterStatus.trash;
    _keep(c);
    _pushChapter(c, then: 'trash');
  }

  void restoreChapter(AuthorChapter c) {
    c.status = c.previousStatus == ChapterStatus.trash ? ChapterStatus.draft : c.previousStatus;
    _keep(c);
    _pushChapter(c, then: 'restore');
  }

  void deleteChapterForever(AuthorChapter c) {
    chapters.removeWhere((x) => x.id == c.id);
    _save();
    final s = story(c.storyId);
    if (c.remoteId.isNotEmpty && s != null && s.remoteId.isNotEmpty) {
      _remote((api) => api.delete('author/stories/${s.remoteId}/chapters/${c.remoteId}/'));
    }
  }

  // ── Contract ───────────────────────────────────────────────────────────────
  /// Published words; Apply for Contract opens at [AppConstants.contractMinWords].
  bool canApplyForContract(AuthorStory s) =>
      !s.signed && s.mayApply && s.isInfoComplete && totalWords(s.id) >= AppConstants.contractMinWords;

  /// Editors an author can choose, (id, name): the desk that matches the book.
  Future<List<(String, String)>> editorsFor(AuthorStory s) async {
    if (!_online || s.remoteId.isEmpty) {
      return [
        for (final (id, name, shorts) in AuthorData.editors)
          if (shorts == s.isShort) (id, name),
      ];
    }
    final rows = (await _api!.get('author/stories/${s.remoteId}/editors/') as List).cast<Map>();
    return [for (final e in rows) (e['id'].toString(), e['name'].toString())];
  }

  /// Sends the application with both ID photos. Throws [ApiException] with
  /// field errors (and the step to go back to) when the server says no.
  Future<void> submitApplication(AuthorStory s, ContractApplication app) async {
    if (!_online) {
      await Future.delayed(const Duration(milliseconds: 600));
    } else {
      await _queue; // the book and its chapters are on the server first
      if (s.remoteId.isEmpty) {
        throw const ApiException(0, "This book hasn't reached Bonovela yet. Check your connection and try again.");
      }
      final row = await _api!.upload('author/stories/${s.remoteId}/application/', app.toFields(), {
        'id_front': app.idFrontPath,
        'id_back': app.idBackPath,
      });
      s.applicationStatus = (row as Map)['status']?.toString() ?? 'pending';
    }
    if (!_online) s.applicationStatus = 'pending';
    stories.refresh();
    _save();
  }

  /// Signs the contract the Chief Editor sent; the book is then signed.
  Future<void> signContract(AuthorStory s) async {
    if (_online) await _api!.post('author/stories/${s.remoteId}/sign/');
    s
      ..signed = true
      ..applicationStatus = 'signed';
    stories.refresh();
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

  // ── Comments ───────────────────────────────────────────────────────────────
  final Map<String, DateTime> _commentsLoaded = {};

  /// Reader comments on [story]: from the server when online (refreshed at
  /// most once a minute), otherwise sample readers.
  List<AuthorComment> commentsFor(AuthorStory story) {
    if (!_online || story.remoteId.isEmpty) return _sampleComments(story);
    final last = _commentsLoaded[story.id];
    if (last == null || DateTime.now().difference(last).inSeconds > 60) {
      _commentsLoaded[story.id] = DateTime.now();
      _loadComments(story);
    }
    return _comments[story.id] ?? [];
  }

  Future<void> _loadComments(AuthorStory story) async {
    try {
      final rows = (await _api!.get('author/comments/', {'book': story.remoteId}) as List).cast<Map>();
      _comments[story.id] = [
        for (final r in rows)
          AuthorComment(
            id: r['id'].toString(),
            storyId: story.id,
            chapterTitle: '',
            user: r['user_name']?.toString() ?? '',
            stars: (r['stars'] as num?)?.toInt() ?? 5,
            text: r['text']?.toString() ?? '',
            date: DateTime.tryParse(r['date']?.toString() ?? '') ?? DateTime.now(),
            likes: (r['likes'] as num?)?.toInt() ?? 0,
            replies: [
              for (final reply in (r['replies'] as List? ?? []).cast<Map>())
                if (reply['is_author'] == true) reply['text'].toString(),
            ],
          ),
      ];
      for (final c in _comments[story.id]!) {
        replies[c.id] = c.replies;
      }
    } catch (_) {}
  }

  void reply(String commentId, String text) {
    replies[commentId] = [...(replies[commentId] ?? []), text];
    _save();
    if (_comments.values.any((list) => list.any((c) => c.id == commentId))) {
      _remote((api) => api.post('author/comments/$commentId/reply/', {'text': text}));
    }
  }

  static const _readers = ['Nasadie', 'Honey Queen', 'Ada', 'Chioma', 'Grace', 'Tolu', 'Jess'];
  static const _texts = [
    'so interesting',
    'The way he shows his concern without outright saying it is amazing',
    'Please update soon, I need the next chapter!',
    'She is so brave, I love her character',
    'This chapter had me in tears 😭',
  ];

  /// Sample-data builds: readers start commenting once chapters are out.
  List<AuthorComment> _sampleComments(AuthorStory story) {
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
}
