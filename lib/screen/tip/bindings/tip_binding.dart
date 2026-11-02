import 'package:get/get.dart';

import '../controller/tip_controller.dart';

/// The tip sheet isn't a route, so it registers its controller by hand,
/// tagged by book, and removes it when the sheet closes.
class TipBinding extends Bindings {
  final String bookId;

  TipBinding(this.bookId);

  @override
  void dependencies() {
    Get.put(TipController(bookId), tag: bookId);
  }

  void dispose() => Get.delete<TipController>(tag: bookId);
}
