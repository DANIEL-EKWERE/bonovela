import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/book_model.dart';
import '../../../core/repository/book_repository.dart';

class RankController extends GetxController {
  final _repo = Get.find<BookRepository>();

  final List<String> genres = ['All', ...AppConstants.genres];
  final List<RankType> types = RankType.values;

  final RxString genre = 'All'.obs;
  final Rx<RankType> type = RankType.bestsellers.obs;
  final RxList<BookModel> books = <BookModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void selectGenre(String g) {
    if (genre.value == g) return;
    genre.value = g;
    load();
  }

  void selectType(RankType t) {
    if (type.value == t) return;
    type.value = t;
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    final g = genre.value == 'All' ? null : genre.value;
    books.assignAll(await _repo.getRanking(type.value, genre: g));
    isLoading.value = false;
  }

  void openSearch() => Get.toNamed(AppRoutes.search);
}
