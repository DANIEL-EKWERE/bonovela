import 'package:get/get.dart';

import '../../../core/models/author_models.dart';
import '../../../core/services/author_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../widgets/ui_kit.dart';

class AuthorStatisticsController extends GetxController {
  final _author = Get.find<AuthorService>();

  late final AuthorStory story;

  @override
  void onInit() {
    super.onInit();
    story = _author.story(Get.arguments as String)!;
  }

  List<AuthorChapter> get _published => _author.published(story.id);

  // ── Release ────────────────────────────────────────────────────────────────
  int get wordsYesterday {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return _author.wordsByDay(story.id)['${y.year}-${y.month}-${y.day}'] ?? 0;
  }

  int get avgChapterLength => _published.isEmpty ? 0 : _author.totalWords(story.id) ~/ _published.length;

  int get updatingDaysThisMonth {
    final now = DateTime.now();
    return _author.wordsByDay(story.id).keys.where((k) => k.startsWith('${now.year}-${now.month}-')).length;
  }

  // ── Reading (mock, grows with chapters) ────────────────────────────────────
  int get subscribers => _published.length * 2;
  int get views => _published.length * 37;
  String get thirdChapterRate => _published.length >= 3 ? '42%' : '0%';

  // ── Interactive ────────────────────────────────────────────────────────────
  int get comments => _author.commentsFor(story).length;
  int get thumbsUp => _published.length * 3;
  int get votes => 0;

  /// Reader gender split for the ring chart: (male, female, unspecified).
  (double, double, double) get genderSplit =>
      _published.isEmpty ? (0, 0, 0) : (story.audience == 'male' ? (0.62, 0.30, 0.08) : (0.18, 0.74, 0.08));

  String get today => Fmt.date(DateTime.now());

  void howToPromote() => toast(
    'Getting promoted',
    'Update daily, keep chapters 600–1,000 words, and complete your book information. Signed books get featured.',
  );
}
