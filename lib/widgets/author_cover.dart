import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_icons.dart';
import '../core/models/author_models.dart';

/// Cover for an author's own story. Uses one of the recommended cover
/// palettes until real image upload exists; shows a "+" placeholder when no
/// cover has been chosen.
class AuthorCover extends StatelessWidget {
  final AuthorStory story;
  final double width;

  /// Overrides [AuthorStory.coverIndex] (the form previews unsaved choices).
  final int? coverIndex;

  /// Overrides [AuthorStory.coverPath] (device photo).
  final String? coverPath;
  final String? title;

  const AuthorCover({super.key, required this.story, this.width = 84, this.coverIndex, this.coverPath, this.title});

  @override
  Widget build(BuildContext context) {
    final index = coverIndex ?? story.coverIndex;
    final text = title ?? story.displayTitle;
    final h = width * 4 / 3;
    final path = coverPath ?? story.coverPath;
    if (path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(path),
          width: width,
          height: h,
          fit: BoxFit.cover,
          // File removed (e.g. app data cleared): fall back to the palette cover.
          errorBuilder: (_, _, _) => AuthorCover(story: story, width: width, coverPath: '', title: title),
        ),
      );
    }
    if (index < 0) {
      return Container(
        width: width,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(AppIcons.add, color: AppColors.textHint, size: 28),
            const SizedBox(height: 4),
            Text(
              'New Story',
              style: TextStyle(color: AppColors.textHint, fontSize: width * 0.11),
            ),
          ],
        ),
      );
    }
    final palette = AppColors.coverPalettes[index % AppColors.coverPalettes.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: width,
        height: h,
        padding: EdgeInsets.all(width * 0.08),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: palette),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: (width * 0.14).clamp(8, 22),
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            SizedBox(height: width * 0.06),
            Text(
              AppConstants.appName.toUpperCase(),
              style: TextStyle(color: Colors.white60, fontSize: (width * 0.06).clamp(6, 10), letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
