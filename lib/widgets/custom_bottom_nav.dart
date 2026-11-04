import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Unread count shown on the Profile tab.
  final int profileBadge;

  const CustomBottomNav({super.key, required this.currentIndex, required this.onTap, this.profileBadge = 0});

  static const _items = [
    (AppIcons.library, AppIcons.libraryFill, 'Library'),
    (AppIcons.discover, AppIcons.discoverFill, 'Discover'),
    (AppIcons.short, AppIcons.shortFill, 'Short'),
    (AppIcons.drama, AppIcons.dramaFill, 'Drama'),
    (AppIcons.user, AppIcons.userFill, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkResponse(
                    onTap: () => onTap(i),
                    highlightShape: BoxShape.rectangle,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Badge(
                          isLabelVisible: i == 4 && profileBadge > 0,
                          label: Text(
                            profileBadge > 99 ? '99+' : '$profileBadge',
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: AppColors.error,
                          child: Icon(
                            i == currentIndex ? _items[i].$2 : _items[i].$1,
                            size: 24,
                            color: i == currentIndex ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _items[i].$3,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: i == currentIndex ? FontWeight.w600 : FontWeight.w400,
                            color: i == currentIndex ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
