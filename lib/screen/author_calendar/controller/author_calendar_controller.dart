import 'package:get/get.dart';

import '../../../core/models/author_models.dart';
import '../../../core/services/author_service.dart';

/// Update calendar: which days of a month a story got new chapters.
class AuthorCalendarController extends GetxController {
  final _author = Get.find<AuthorService>();

  final RxnString storyId = RxnString();
  final Rx<DateTime> month = DateTime(DateTime.now().year, DateTime.now().month).obs;

  RxList<AuthorStory> get stories => _author.stories;

  AuthorStory? get story {
    final id = storyId.value;
    final list = _author.stories;
    if (list.isEmpty) return null;
    return list.firstWhereOrNull((s) => s.id == id) ?? list.first;
  }

  void selectStory(String id) => storyId.value = id;

  void selectMonth(int year, int m) => month.value = DateTime(year, m);

  /// Day → words published that day, for the selected story and month.
  Map<int, int> get wordsByDay {
    _author.chapters.length; // reactive
    final s = story;
    if (s == null) return {};
    final m = month.value;
    final out = <int, int>{};
    _author.wordsByDay(s.id).forEach((key, words) {
      final p = key.split('-').map(int.parse).toList();
      if (p[0] == m.year && p[1] == m.month) out[p[2]] = words;
    });
    return out;
  }

  int get wordsThisMonth => wordsByDay.values.fold(0, (a, b) => a + b);

  int get daysInMonth => DateTime(month.value.year, month.value.month + 1, 0).day;

  /// 0 = Sunday, to offset the first row.
  int get firstWeekday => DateTime(month.value.year, month.value.month, 1).weekday % 7;

  bool isFuture(int day) => DateTime(month.value.year, month.value.month, day).isAfter(DateTime.now());
}
