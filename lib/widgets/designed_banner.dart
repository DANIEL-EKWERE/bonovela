import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/services/ads_service.dart';

/// A banner made in Marketing's banner builder: background (image or
/// colours), the book's cover, headline, description and a button, each
/// placed in percent of the banner so every screen size matches the
/// preview. Tapping anywhere opens the promoted book ([onTap]).
class DesignedBanner extends StatelessWidget {
  final AdBanner ad;
  final VoidCallback onTap;

  const DesignedBanner({super.key, required this.ad, required this.onTap});

  static Color _color(Object? hex, Color fallback) {
    final s = (hex ?? '').toString().replaceFirst('#', '');
    final v = int.tryParse(s.length == 6 ? 'FF$s' : s, radix: 16);
    return v == null ? fallback : Color(v);
  }

  static double _num(Object? v, double fallback) => v is num ? v.toDouble() : fallback;

  Map<String, dynamic> _part(String key) {
    final v = ad.design[key];
    return v is Map ? Map<String, dynamic>.from(v) : const {};
  }

  static String? _font(Object? f) => switch (f) {
    'serif' => 'serif',
    'script' => 'cursive',
    _ => null,
  };

  static TextAlign _align(Object? a) => switch (a) {
    'left' => TextAlign.left,
    'right' => TextAlign.right,
    _ => TextAlign.center,
  };

  @override
  Widget build(BuildContext context) {
    final bg = _part('bg');
    final cover = _part('cover');
    final head = _part('headline');
    final body = _part('body');
    final button = _part('button');
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (_, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;
          final scale = w / 360;
          // Centre of an element at (x%, y%), like the web preview.
          Widget at(Map p, double width, Widget child) => Positioned(
            left: w * _num(p['x'], 50) / 100 - width / 2,
            top: h * _num(p['y'], 50) / 100,
            width: width,
            child: FractionalTranslation(translation: const Offset(0, -0.5), child: child),
          );
          Widget text(Map p, String value) => Text(
            value,
            textAlign: _align(p['align']),
            style: TextStyle(
              color: _color(p['color'], Colors.white),
              fontSize: _num(p['size'], 16) * scale,
              fontWeight: FontWeight.values[((_num(p['weight'], 400) ~/ 100) - 1).clamp(0, 8)],
              fontFamily: _font(p['font']),
              height: 1.25,
              shadows: const [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(0, 1))],
            ),
          );
          final c1 = _color(bg['c1'], const Color(0xFF7A1F33));
          final c2 = _color(bg['c2'], const Color(0xFF2B1E20));
          final coverW = w * _num(cover['w'], 40) / 100;
          final style = button['style'] ?? 'pill';
          final btnColor = _color(button['bg'], const Color(0xFFB8242F));
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: bg['type'] == 'image' && ad.imageUrl.isNotEmpty
                    ? CachedNetworkImage(imageUrl: ad.imageUrl, fit: BoxFit.cover)
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: c1,
                          gradient: bg['type'] == 'color'
                              ? null
                              : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, c2]),
                        ),
                      ),
              ),
              Positioned.fill(
                child: ColoredBox(color: Colors.black.withValues(alpha: _num(bg['overlay'], 0) / 100)),
              ),
              if (cover['show'] != false && ad.coverUrl.isNotEmpty)
                Positioned(
                  left: w * _num(cover['x'], 50) / 100 - coverW / 2,
                  top: h * _num(cover['y'], 35) / 100 - coverW * 4 / 3 / 2,
                  width: coverW,
                  height: coverW * 4 / 3,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      boxShadow: [BoxShadow(blurRadius: 18, color: Colors.black45, offset: Offset(0, 6))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(imageUrl: ad.coverUrl, fit: BoxFit.cover),
                    ),
                  ),
                ),
              if (ad.title.isNotEmpty) at(head, w * 0.86, text(head, ad.title)),
              if (ad.subtitle.isNotEmpty) at(body, w * 0.86, text(body, ad.subtitle)),
              at(
                button,
                w * 0.9,
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 26 * scale, vertical: 9 * scale),
                    decoration: BoxDecoration(
                      color: style == 'outline' ? Colors.transparent : btnColor,
                      border: Border.all(color: btnColor, width: 2),
                      borderRadius: BorderRadius.circular(style == 'rounded' ? 10 : 999),
                    ),
                    child: Text(
                      '${button['text'] ?? 'View More'} ›',
                      style: TextStyle(
                        color: _color(button['color'], Colors.white),
                        fontSize: _num(button['size'], 15) * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
