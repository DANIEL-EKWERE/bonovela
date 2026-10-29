import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/wallet_models.dart';
import '../../../core/services/account_service.dart';

class UnlockedBook {
  final BookModel book;
  final List<int> chapters;
  final DateTime lastUnlock;

  const UnlockedBook(this.book, this.chapters, this.lastUnlock);
}

class ChapterUnlockedController extends GetxController {
  final _account = Get.find<AccountService>();

  /// Unlock transactions grouped by book, most recent first.
  List<UnlockedBook> get books {
    final groups = <String, List<WalletTransaction>>{};
    for (final t in _account.transactions.where((t) => t.kind == TxKind.unlock && t.bookId != null)) {
      groups.putIfAbsent(t.bookId!, () => []).add(t);
    }
    return [
      for (final e in groups.entries)
        if (MockData.books.firstWhereOrNull((b) => b.id == e.key) case final book?)
          UnlockedBook(book, (e.value.map((t) => t.chapter ?? 0).toList()..sort()), e.value.first.date),
    ];
  }

  void open(UnlockedBook u) => Get.toNamed(AppRoutes.bookDetail, arguments: u.book.id, preventDuplicates: false);
}
