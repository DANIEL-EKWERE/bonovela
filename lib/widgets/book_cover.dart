import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/models/book_model.dart';

/// Book cover with optional rank number (top-left), corner badge (top-right)
/// and rating (bottom-right). Draws a typographic placeholder while the book
/// has no cover image.
class BookCover extends StatelessWidget {
  final BookModel book;
  final double width;
  final double? height;
  final int? rank;
  final String? badge;
  final bool showRating;
  final double radius;

  const BookCover({
    super.key,
    required this.book,
    required this.width,
    this.height,
    this.rank,
    this.badge,
    this.showRating = false,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? width * 4 / 3;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            book.coverUrl.isEmpty
                ? _Placeholder(book: book, width: width)
                : CachedNetworkImage(
                    imageUrl: book.coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(color: AppColors.surface),
                    errorWidget: (_, _, _) => _Placeholder(book: book, width: width),
                  ),
            if (rank != null)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: rank! <= 3 ? AppColors.primary : AppColors.plum.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(6)),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6)),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (showRating)
              Positioned(
                right: 4,
                bottom: 3,
                child: Text(
                  book.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final BookModel book;
  final double width;

  const _Placeholder({required this.book, required this.width});

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.coverPalettes[book.coverSeed % AppColors.coverPalettes.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
      ),
      padding: EdgeInsets.all(width * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: width * 0.25, height: 1.5, color: Colors.white54),
          SizedBox(height: width * 0.06),
          Text(
            book.title,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: (width * 0.13).clamp(8, 22),
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          SizedBox(height: width * 0.06),
          if (width > 60)
            Text(
              book.author.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontSize: (width * 0.065).clamp(6, 11),
                letterSpacing: 1.2,
              ),
            ),
        ],
      ),
    );
  }
}
