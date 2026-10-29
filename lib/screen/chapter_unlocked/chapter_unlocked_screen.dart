import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/chapter_unlocked_controller.dart';

class ChapterUnlockedScreen extends GetView<ChapterUnlockedController> {
  const ChapterUnlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Chapter Unlocked',
      background: Colors.white,
      bottom: GradientButton(label: 'Get more bonus!', onTap: () => Get.toNamed(AppRoutes.rewards)),
      body: Obx(() {
        final books = controller.books;
        if (books.isEmpty) {
          return const EmptyState(
            icon: Icons.lock_open_rounded,
            message: 'Chapters you unlock with coins or bonus will be listed here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: books.length,
          separatorBuilder: (_, _) => const Divider(indent: 16, endIndent: 16),
          itemBuilder: (_, i) {
            final u = books[i];
            return InkWell(
              onTap: () => controller.open(u),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    BookCover(book: u.book, width: 60),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.book.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            '${u.chapters.length} chapter${u.chapters.length == 1 ? '' : 's'}: '
                            '${u.chapters.take(6).join(', ')}${u.chapters.length > 6 ? '…' : ''}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(Fmt.date(u.lastUnlock),
                              style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
