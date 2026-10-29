import 'package:get/get.dart';

import '../../../core/models/book_model.dart';

/// Full list behind a section's "More" link.
class ViewAllController extends GetxController {
  late final String title;
  late final List<BookModel> books;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map;
    title = args['title'] as String;
    books = (args['books'] as List).cast<BookModel>();
  }
}
