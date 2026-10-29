import 'package:get/get.dart';

import '../../../config/local_storage.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/book_model.dart';
import '../../../core/services/account_service.dart';

class AutoSubscriptionController extends GetxController {
  final _account = Get.find<AccountService>();
  final _storage = Get.find<LocalStorage>();

  /// Paid novels the reader has shelved or opened.
  List<BookModel> get books {
    final ids = <String>{..._storage.shelf, ..._storage.history.map((p) => p.bookId), ..._account.autoUnlockBooks};
    return [
      for (final id in ids) ?MockData.books.firstWhereOrNull((b) => b.id == id && !b.isShort),
    ];
  }

  bool isOn(String id) => _account.autoUnlockBooks.contains(id);

  void toggle(String id, bool on) => _account.setAutoUnlock(id, on);
}
