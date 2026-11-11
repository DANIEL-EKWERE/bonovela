import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/feed_section.dart';
import '../../../core/repository/book_repository.dart';
import '../../../core/utils/formatters.dart';
import '../../../widgets/ui_kit.dart';

class ShortController extends GetxController {
  final _repo = Get.find<BookRepository>();

  final List<String> tabs = const ['Home', 'Selected', 'New Arrivals'];
  final List<String> homeSegments = const ['Collection', 'Top Trending', 'Hottest New'];

  final RxBool isLoading = true.obs;
  final RxList<BookModel> shorts = <BookModel>[].obs;

  /// The Treasure Collection: categories of curated shelves.
  final RxList<ShortCollection> collections = <ShortCollection>[].obs;
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
    try {
      final results = await Future.wait([_repo.getShorts(), _repo.getShortCollections()]);
      shorts.assignAll(results[0] as List<BookModel>);
      collections.assignAll(results[1] as List<ShortCollection>);
    } catch (_) {
      toast('Short Stories', "Couldn't load stories. Pull down to try again.");
    } finally {
      isLoading.value = false;
    }
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

  List<String> get arrivalFilters => [
    'All',
    ...{for (final b in shorts) b.genre},
  ];

  /// New arrivals grouped by day, newest first.
  Map<String, List<BookModel>> get arrivalsByDate {
    final list = shorts.where((b) => arrivalFilter.value == 'All' || b.genre == arrivalFilter.value).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final groups = <String, List<BookModel>>{};
    for (final b in list) {
      groups.putIfAbsent(Fmt.date(b.updatedAt), () => []).add(b);
    }
    return groups;
  }

  void openSearch() => Get.toNamed(AppRoutes.search);
}
