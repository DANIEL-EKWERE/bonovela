import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';
import '../core/models/drama_model.dart';
import '../core/utils/formatters.dart';
import 'book_cover.dart';

/// Drama poster: "Drama"/"Adapted" tag top-left and play count bottom-left.
class DramaCover extends StatelessWidget {
  final DramaModel drama;
  final double width;
  final double? height;
  final double radius;

  const DramaCover({super.key, required this.drama, required this.width, this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    final small = width < 90;
    return SizedBox(
      width: width,
      height: height ?? width * 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BookCover(book: drama.asBook, width: width, height: height ?? width * 4 / 3, radius: radius),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: small ? 5 : 7, vertical: 2),
              decoration: BoxDecoration(
                color: drama.isAdapted ? AppColors.plumLight : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius),
                  bottomRight: const Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.video, size: small ? 10 : 12, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(
                    drama.kindLabel,
                    style: TextStyle(color: Colors.white, fontSize: small ? 9 : 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 14, 6, 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.playFill, size: small ? 10 : 12, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(
                    Fmt.compact(drama.plays),
                    style: TextStyle(color: Colors.white, fontSize: small ? 10 : 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
