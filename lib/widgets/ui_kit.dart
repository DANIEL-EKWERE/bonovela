import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';

/// Short confirmation at the bottom of the screen.
void toast(String title, [String message = '']) {
  Get.closeCurrentSnackbar();
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.plum.withValues(alpha: 0.95),
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    duration: const Duration(seconds: 2),
    messageText: message.isEmpty ? const SizedBox.shrink() : null,
  );
}

/// Grey page with a plain white app bar, used by most secondary screens.
class SubPage extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottom;
  final Color background;

  const SubPage({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottom,
    this.background = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(onPressed: Get.back, icon: const Icon(AppIcons.back, size: 20)),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              child: Padding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 12), child: bottom),
            ),
    );
  }
}

class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const WhiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: child,
  );
}

/// Row with optional leading icon, trailing value/widget and a chevron.
class MenuTile extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool chevron;

  const MenuTile({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
    this.chevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22, color: iconColor ?? AppColors.textPrimary),
              const SizedBox(width: 14),
            ],
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
            if (value != null) Text(value!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ?trailing,
            if (chevron && onTap != null) const Icon(AppIcons.chevronRight, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

/// Small pill action used in task lists ("Go", "Claim", "Done").
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  const PillButton({super.key, required this.label, this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 64),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          gradient: filled && enabled ? AppColors.buttonGradient : null,
          color: filled && enabled ? null : (enabled ? AppColors.blush : AppColors.surface),
          borderRadius: BorderRadius.circular(18),
        ),
        // A min-size Row centres the label without stretching to the
        // parent's width (matters inside ListTile.trailing).
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled && enabled ? Colors.white : (enabled ? AppColors.primary : AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Coins / bonus / voucher icon with consistent colours.
class CurrencyIcon extends StatelessWidget {
  final String kind; // coins | bonus | voucher
  final double size;

  const CurrencyIcon(this.kind, {super.key, this.size = 18});

  @override
  Widget build(BuildContext context) => switch (kind) {
    'bonus' => Icon(AppIcons.bonus, color: AppColors.primary, size: size),
    'voucher' => Icon(AppIcons.voucher, color: AppColors.voucher, size: size),
    _ => Icon(AppIcons.coin, color: AppColors.gold, size: size),
  };
}
