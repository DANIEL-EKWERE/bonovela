import 'package:get/get.dart';

import '../../config/local_storage.dart';
import '../../config/routes.dart';
import '../api/api_client.dart';
import '../constants/app_constants.dart';

/// A Marketing banner shown as a pop-up or open-screen ad.
class AdBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String target; // story | drama | url | store | plus
  final String? storyId;
  final String? dramaId;

  const AdBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.target,
    this.storyId,
    this.dramaId,
  });

  factory AdBanner.fromJson(Map<String, dynamic> j) => AdBanner(
    id: j['id'].toString(),
    title: j['title']?.toString() ?? '',
    subtitle: j['subtitle']?.toString() ?? '',
    imageUrl: j['image_url']?.toString() ?? '',
    target: j['target']?.toString() ?? '',
    storyId: j['story_id']?.toString(),
    dramaId: j['drama_id']?.toString(),
  );
}

/// Pop-up and open-screen ads set up by Marketing (Banners, placements
/// "popup" and "splash"). Each ad is shown once per device.
class AdsService extends GetxService {
  static const splash = 'splash';
  static const popup = 'popup';
  static const _kSeen = 'seen_ads';

  LocalStorage get _storage => Get.find<LocalStorage>();
  ApiClient? get _api => Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null;

  bool get enabled => AppConstants.apiUrl.isNotEmpty;

  Set<String> get _seen => (_storage.read<List>(_kSeen) ?? []).map((e) => e.toString()).toSet();

  /// The first live ad of [placement] this device hasn't seen, or null (also
  /// when offline or slow: ads never hold up the app).
  Future<AdBanner?> nextUnseen(String placement, {Duration timeout = const Duration(seconds: 3)}) async {
    final api = _api;
    if (!enabled || api == null) return null;
    try {
      final rows = await api.get('banners/', {'placement': placement}).timeout(timeout) as List;
      final seen = _seen;
      for (final r in rows) {
        final ad = AdBanner.fromJson(Map<String, dynamic>.from(r));
        if (!seen.contains(ad.id) && ad.imageUrl.isNotEmpty) return ad;
      }
    } catch (_) {}
    return null;
  }

  void markSeen(AdBanner ad) => _storage.write(_kSeen, [..._seen, ad.id]);

  /// "View More": count the click and go where the ad points.
  void open(AdBanner ad) {
    _api?.post('banners/${ad.id}/click/').catchError((_) => null);
    switch (ad.target) {
      case 'story' when ad.storyId != null:
        Get.toNamed(AppRoutes.bookDetail, arguments: ad.storyId);
      case 'drama' when ad.dramaId != null:
        Get.toNamed(AppRoutes.dramaPlayer, arguments: {'dramaId': ad.dramaId});
      case 'store':
        Get.toNamed(AppRoutes.topUp);
      case 'plus':
        Get.toNamed(AppRoutes.subscription);
    }
  }
}
