import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_colors.dart';

/// Layout shared by the email / password steps: a blush strip at the top
/// and a white rounded sheet with a close button.
class AuthSheet extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final List<Widget> children;

  /// Round arrow / check button at the bottom right of the form.
  final Widget? action;

  const AuthSheet({super.key, required this.title, this.subtitle, required this.children, this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blushDeep,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.blush, Color(0xFFF7D7F5)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    onPressed: Get.back,
                    icon: const Icon(Icons.close_rounded, size: 28),
                  ),
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.25)),
                if (subtitle != null) ...[const SizedBox(height: 8), subtitle!],
                const SizedBox(height: 24),
                ...children,
                if (action != null) ...[
                  const SizedBox(height: 24),
                  Align(alignment: Alignment.centerRight, child: action),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Field label above an input.
class AuthLabel extends StatelessWidget {
  final String text;

  const AuthLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
      );
}

/// Round gradient button with an icon (→ or ✓).
class RoundActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;

  const RoundActionButton({super.key, required this.icon, this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.buttonGradient,
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

/// Password field with a show/hide toggle.
class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final RxBool obscure;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const PasswordField({
    super.key,
    required this.controller,
    required this.hint,
    required this.obscure,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => TextField(
          controller: controller,
          obscureText: obscure.value,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            suffixIcon: IconButton(
              onPressed: obscure.toggle,
              icon: Icon(obscure.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textHint),
            ),
          ),
        ));
  }
}
