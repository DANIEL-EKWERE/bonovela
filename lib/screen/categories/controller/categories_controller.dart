import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/book_model.dart';

class CategoriesController extends GetxController {
  final genres = ['All', ...AppConstants.genres];
  final audiences = const ['All', 'Female', 'Male'];
  final statuses = const ['All', 'Completed', 'Ongoing'];
  final formats = const ['All', 'Novels', 'Shorts'];

  final RxString genre = 'All'.obs;
  final RxString audience = 'All'.obs;
  final RxString status = 'All'.obs;
  final RxString format = 'All'.obs;

  /// Mock audience split: urban and fantasy lean male, the rest female.
  static String audienceOf(BookModel b) => (b.genre == 'Urban' || b.genre == 'Fantasy') ? 'Male' : 'Female';

  List<BookModel> get results {
    final list = MockData.books.where((b) {
      if (genre.value != 'All' && b.genre != genre.value) return false;
      if (audience.value != 'All' && audienceOf(b) != audience.value) return false;
      if (status.value == 'Completed' && !b.isCompleted) return false;
      if (status.value == 'Ongoing' && b.isCompleted) return false;
      if (format.value == 'Novels' && b.isShort) return false;
      if (format.value == 'Shorts' && !b.isShort) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.views.compareTo(a.views));
    return list;
  }

  void reset() {
    genre.value = 'All';
    audience.value = 'All';
    status.value = 'All';
    format.value = 'All';
  }
}
