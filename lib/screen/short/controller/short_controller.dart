import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/book_model.dart';
import '../../../core/repository/book_repository.dart';
import '../../../core/utils/formatters.dart';

/// A themed group of shorts, e.g. "Werewolves & Vampires".
class ShortCollection {
  final String title;
  final String subtitle;
  final List<BookModel> books;

  const ShortCollection(this.title, this.subtitle, this.books);
}

class ShortController extends GetxController {
  final _repo = Get.find<BookRepository>();

  final List<String> tabs = const ['Home', 'Selected', 'New Arrivals'];
  final List<String> homeSegments = const ['Collection', 'Top Trending', 'Hottest New'];

  final RxBool isLoading = true.obs;
  final RxList<BookModel> shorts = <BookModel>[].obs;
  final RxInt segment = 0.obs;

  /// New Arrivals filter: 'All' or a genre.
  final RxString arrivalFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    shorts.assignAll(await _repo.getShorts());
    isLoading.value = false;
  }

  List<BookModel> get segmentBooks {
    final list = [...shorts];
    switch (segment.value) {
      case 1:
        list.sort((a, b) => b.views.compareTo(a.views));
      case 2:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    return list.take(6).toList();
  }

  List<ShortCollection> get collections {
    List<BookModel> withGenre(String g) => shorts.where((b) => b.genre == g).toList();
    List<BookModel> withTag(String t) =>
        shorts.where((b) => b.tags.any((x) => x.contains(t))).toList();
    return [
      ShortCollection('Handpicked Books', 'Chosen by our editors', shorts.take(4).toList()),
      ShortCollection('Werewolves & Vampires', 'Fated bonds, broken hearts', withGenre('Werewolf')),
      ShortCollection('Betrayal & Comeback', 'Underestimate me, regret it', [...withTag('Revenge'), ...withTag('Regret')]),
      ShortCollection('Second Life', 'This time, I choose myself', withTag('Rebirth')),
    ].where((c) => c.books.isNotEmpty).toList();
  }

  List<String> get arrivalFilters =>
      ['All', ...{for (final b in shorts) b.genre}];

  /// New arrivals grouped by day, newest first.
  Map<String, List<BookModel>> get arrivalsByDate {
    final list = shorts
        .where((b) => arrivalFilter.value == 'All' || b.genre == arrivalFilter.value)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final groups = <String, List<BookModel>>{};
    for (final b in list) {
      groups.putIfAbsent(Fmt.date(b.updatedAt), () => []).add(b);
    }
    return groups;
  }

  void openSearch() => Get.toNamed(AppRoutes.search);
}
