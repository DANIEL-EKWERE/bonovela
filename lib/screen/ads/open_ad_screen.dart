import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/ads_service.dart';

/// Full-screen open-screen ad shown after the splash: Skip countdown in the
/// corner, VIEW MORE at the bottom. Arguments: {'ad': AdBanner, 'next': route}.
class OpenAdScreen extends StatefulWidget {
  const OpenAdScreen({super.key});

  @override
  State<OpenAdScreen> createState() => _OpenAdScreenState();
}

class _OpenAdScreenState extends State<OpenAdScreen> {
  static const _seconds = 3;
  late final AdBanner ad = (Get.arguments as Map)['ad'] as AdBanner;
  late final String next = (Get.arguments as Map)['next'] as String;
  int left = _seconds;
  Timer? _timer;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    Get.find<AdsService>().markSeen(ad);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (left <= 1) return _continue();
      setState(() => left--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _continue({bool viewMore = false}) {
    if (_left) return;
    _left = true;
    _timer?.cancel();
    Get.offAllNamed(next);
    if (viewMore) Get.find<AdsService>().open(ad);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: ad.imageUrl,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => const SizedBox.shrink(),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: _continue,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: Text('Skip $left', style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 56),
                child: _ViewMore(onTap: () => _continue(viewMore: true)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// White-outlined pill with a pink-to-orange border, as on the ad designs.
class _ViewMore extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewMore({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(colors: [Color(0xFFFF3D8B), Color(0xFFFF9A3C)]),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 12),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: .35), borderRadius: BorderRadius.circular(28)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'VIEW MORE',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 10),
            Icon(Icons.chevron_right, color: Color(0xFFFF9A3C)),
          ],
        ),
      ),
    ),
  );
}

/// Pop-up ad over the home screen: picture, line of text, View More, ×.
Future<void> showPopupAd(AdBanner ad) {
  final ads = Get.find<AdsService>()..markSeen(ad);
  return Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CachedNetworkImage(imageUrl: ad.imageUrl, fit: BoxFit.cover, width: double.infinity),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Column(
                    children: [
                      if ((ad.subtitle.isNotEmpty ? ad.subtitle : ad.title).isNotEmpty)
                        Text(
                          ad.subtitle.isNotEmpty ? ad.subtitle : ad.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      const SizedBox(height: 14),
                      _ViewMore(
                        onTap: () {
                          Get.back();
                          ads.open(ad);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    ),
    barrierColor: Colors.black54,
  );
}
