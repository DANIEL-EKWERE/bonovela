import 'package:get/get.dart';

import '../controller/book_detail_controller.dart';

class BookDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Tagged by book id: "You might like" pushes another detail page on top.
    final bookId = Get.arguments as String;
    Get.put(BookDetailController(bookId), tag: bookId);
  }
}
