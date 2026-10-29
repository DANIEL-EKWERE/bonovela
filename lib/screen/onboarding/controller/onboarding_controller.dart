import 'package:get/get.dart';

import '../../../config/local_storage.dart';
import '../../../config/routes.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/services/account_service.dart';

/// First launch: pick Female or Male novels. The choice fills the shelf with
/// recommended books, then the app opens on the Library tab.
class OnboardingController extends GetxController {
  final _account = Get.find<AccountService>();
  final _storage = Get.find<LocalStorage>();

  static const kRecommended = 'recommended';

  static const _female = ['Romance', 'Werewolf', 'Mafia'];
  static const _male = ['Urban', 'Fantasy'];

  void choose(String type) => _finish(type);

  void skip() => _finish('');

  void _finish(String type) {
    _account.completeOnboarding(type);
    final genres = switch (type) {
      'female' => _female,
      'male' => _male,
      _ => [..._female, ..._male],
    };
    final picks = (MockData.books.where((b) => genres.contains(b.genre)).toList()
          ..sort((a, b) => b.rating.compareTo(a.rating)))
        .take(9)
        .toList();
    // Insert lowest first so the best pick ends up at the top of the shelf.
    for (final b in picks.reversed) {
      _storage.addToShelf(b.id);
    }
    _storage.write(kRecommended, picks.map((b) => b.id).toList());
    Get.offAllNamed(AppRoutes.main, arguments: {'tab': 0});
  }
}
