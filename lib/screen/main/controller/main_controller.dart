import 'package:get/get.dart';

import '../../../config/local_storage.dart';
import '../../../config/routes.dart';
import '../../../core/models/book_model.dart';
import '../../../core/repository/book_repository.dart';
import '../../../core/services/account_service.dart';

class MainController extends GetxController {
  final _storage = Get.find<LocalStorage>();
  final _repo = Get.find<BookRepository>();

  /// 0 Library · 1 Discover · 2 Short · 3 Rank · 4 Profile
  final RxInt currentIndex = 1.obs;

  /// Book behind the "Continue reading" bar.
  final Rxn<BookModel> lastRead = Rxn<BookModel>();
  final RxInt lastChapter = 1.obs;
  final RxBool continueDismissed = false.obs;

  @override
  void onInit() {
    super.onInit();
    final tab = (Get.arguments as Map?)?['tab'];
    if (tab is int) currentIndex.value = tab;
    _loadLastRead();
    ever(_storage.history, (_) => _loadLastRead());
  }

  int get unread => Get.find<AccountService>().unreadCount;

  void changeTab(int index) => currentIndex.value = index;

  Future<void> _loadLastRead() async {
    final progress = _storage.history.firstOrNull;
    if (progress == null) {
      lastRead.value = null;
      return;
    }
    lastChapter.value = progress.chapter;
    if (lastRead.value?.id != progress.bookId) {
      lastRead.value = await _repo.getBook(progress.bookId);
    }
  }

  void continueReading() {
    final book = lastRead.value;
    if (book == null) return;
    Get.toNamed(AppRoutes.reader, arguments: {'bookId': book.id, 'chapter': lastChapter.value});
  }

  void dismissContinue() => continueDismissed.value = true;
}
