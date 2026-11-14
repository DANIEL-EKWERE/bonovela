import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_colors.dart';
import '../core/services/ads_service.dart';

/// Marketing's banners for [placement], swiping on their own every 4s with
/// dots underneath. Shows nothing when there are none.
class BannerCarousel extends StatefulWidget {
  final String placement;

  const BannerCarousel({super.key, required this.placement});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _pages = PageController(viewportFraction: 0.92);
  List<AdBanner> _ads = [];
  int _index = 0;
  Timer? _auto;

  @override
  void initState() {
    super.initState();
    Get.find<AdsService>().banners(widget.placement).then((ads) {
      if (!mounted || ads.isEmpty) return;
      setState(() => _ads = ads);
      _auto = Timer.periodic(const Duration(seconds: 4), (_) {
        if (_pages.hasClients) {
          _pages.animateToPage(
            (_index + 1) % _ads.length,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _auto?.cancel();
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ads.isEmpty) return const SizedBox.shrink();
    final height = (MediaQuery.sizeOf(context).width - 32) * 0.45;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: PageView.builder(
              controller: _pages,
              itemCount: _ads.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => Get.find<AdsService>().open(_ads[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _ads[i].coverOnly
                        ? _BookCard(ad: _ads[i])
                        : CachedNetworkImage(imageUrl: _ads[i].imageUrl, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          if (_ads.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _ads.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == _index ? 14 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i == _index ? AppColors.primary : AppColors.divider,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


/// A book promotion without artwork: cover, label, title and tagline on
/// the brand gradient.
class _BookCard extends StatelessWidget {
  final AdBanner ad;

  const _BookCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.plum, AppColors.plumLight])),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(imageUrl: ad.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ad.label.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                    child: Text(ad.label, style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                Text(
                  ad.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                if (ad.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    ad.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
