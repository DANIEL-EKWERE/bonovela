import 'package:get/get.dart';

import '../../../config/local_storage.dart';
import '../../../config/routes.dart';
import '../../../core/models/book_model.dart';
import '../../../core/repository/book_repository.dart';
import '../../onboarding/controller/onboarding_controller.dart';

class LibraryController extends GetxController {
  final _repo = Get.find<BookRepository>();
  final _storage = Get.find<LocalStorage>();

  /// 0 = Reading (shelf), 1 = Viewed (history)
  final RxInt tabIndex = 0.obs;

  final RxList<BookModel> shelfBooks = <BookModel>[].obs;
  final RxList<BookModel> viewedBooks = <BookModel>[].obs;
  final RxList<BookModel> banner = <BookModel>[].obs;
  final RxInt bannerIndex = 0.obs;
  final RxBool isLoading = true.obs;

  /// Shelf filter: All · Novels · Shorts
  final RxString filter = 'All'.obs;
  static const filters = ['All', 'Novels', 'Shorts'];

  List<BookModel> get filteredShelf => switch (filter.value) {
        'Novels' => shelfBooks.where((b) => !b.isShort).toList(),
        'Shorts' => shelfBooks.where((b) => b.isShort).toList(),
        _ => shelfBooks.toList(),
      };

  /// Picked during onboarding; badged until the reader opens them.
  bool isRecommended(BookModel b) =>
      (_storage.read<List>(OnboardingController.kRecommended) ?? []).contains(b.id) &&
      _storage.progressFor(b.id) == null;

  /// Library is mock-backed, so ids resolve from the full catalogue once.
  final Map<String, BookModel> _catalogue = {};

  @override
  void onInit() {
    super.onInit();
    _load();
    ever(_storage.shelf, (_) => _resolve());
    ever(_storage.history, (_) => _resolve());
  }

  Future<void> _load() async {
    isLoading.value = true;
    final all = [...await _repo.getBooks(), ...await _repo.getShorts()];
    _catalogue
      ..clear()
      ..addEntries(all.map((b) => MapEntry(b.id, b)));
    banner.assignAll((all.where((b) => !b.isShort).toList()
          ..sort((a, b) => b.rating.compareTo(a.rating)))
        .take(5));
    _resolve();
    isLoading.value = false;
  }

  void _resolve() {
    shelfBooks.assignAll(_storage.shelf.map((id) => _catalogue[id]).whereType<BookModel>());
    viewedBooks.assignAll(
      _storage.history.map((p) => _catalogue[p.bookId]).whereType<BookModel>(),
    );
  }

  DateTime? lastReadAt(String bookId) => _storage.progressFor(bookId)?.readAt;

  int? lastChapter(String bookId) => _storage.progressFor(bookId)?.chapter;

  void openBook(BookModel book) {
    final progress = _storage.progressFor(book.id);
    if (progress != null) {
      Get.toNamed(AppRoutes.reader, arguments: {'bookId': book.id, 'chapter': progress.chapter});
    } else {
      Get.toNamed(AppRoutes.bookDetail, arguments: book.id);
    }
  }

  void openSearch() => Get.toNamed(AppRoutes.search);

  void openRewards() => Get.toNamed(AppRoutes.rewards);

  void removeFromShelf(BookModel book) => _storage.toggleShelf(book.id);

  void clearHistory() => _storage.clearHistory();

  Future<void> reload() => _load();
}
