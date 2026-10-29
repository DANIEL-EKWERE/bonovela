import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Pink pill button used for READ, TOP UP, Continue, etc.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final double? width;
  final double fontSize;
  final bool loading;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.height = 48,
    this.width,
    this.fontSize = 16,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: height,
          width: width,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Section title with an optional "More" link.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMore;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.onMore,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          if (onMore != null)
            GestureDetector(
              onTap: onMore,
              child: const Text(
                'More',
                style: TextStyle(color: AppColors.primary, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small coloured tag text, e.g. "Alpha · Second Chance".
class TagText extends StatelessWidget {
  final List<String> tags;
  final int max;

  const TagText(this.tags, {super.key, this.max = 2});

  @override
  Widget build(BuildContext context) {
    return Text(
      tags.take(max).join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: AppColors.tag, fontSize: 12),
    );
  }
}

/// Grey rounded chip used for tags.
class TagChip extends StatelessWidget {
  final String label;

  const TagChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}

/// Five stars filled to [rating] out of 10.
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;

  const RatingStars({super.key, required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final stars = rating / 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            stars >= i + 1
                ? Icons.star_rounded
                : stars > i
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: size,
            color: AppColors.star,
          ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(color: AppColors.star, fontSize: size - 2),
        ),
      ],
    );
  }
}

/// Rounded search field look-alike that opens the search screen.
class SearchBarButton extends StatelessWidget {
  final VoidCallback onTap;

  const SearchBarButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
            SizedBox(width: 8),
            Text('Search...', style: TextStyle(color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: AppColors.blushDeep),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              GradientButton(label: actionLabel!, onTap: onAction, height: 40, fontSize: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
      );
}

/// Blush gradient that sits behind the top of a tab screen.
class HeaderBackground extends StatelessWidget {
  final Widget child;

  const HeaderBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(height: 200, decoration: const BoxDecoration(gradient: AppColors.headerGradient)),
        child,
      ],
    );
  }
}
