import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/inbox_message.dart';
import '../../../core/services/account_service.dart';

class InboxController extends GetxController {
  final _account = Get.find<AccountService>();

  RxList<InboxMessage> get messages => _account.inbox;

  void open(InboxMessage m) {
    _account.markRead(m);
    if (m.bookId != null) {
      Get.toNamed(AppRoutes.bookDetail, arguments: m.bookId, preventDuplicates: false);
    }
  }

  void markAllRead() => _account.markAllRead();

  void delete(InboxMessage m) => _account.deleteMessage(m);
}
