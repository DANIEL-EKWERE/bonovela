import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/repository/book_repository.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/book_tiles.dart';
import '../../widgets/common.dart';
import 'controller/rank_controller.dart';

class RankScreen extends GetView<RankController> {
  const RankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeaderBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: SearchBarButton(onTap: controller.openSearch),
              ),
              _GenreTabs(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TypeRail(),
                    Expanded(child: _RankList()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreTabs extends GetView<RankController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Obx(() => ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              for (final g in controller.genres)
                GestureDetector(
                  onTap: () => controller.selectGenre(g),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          g,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: controller.genre.value == g ? FontWeight.w700 : FontWeight.w400,
                            color: controller.genre.value == g
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          width: 16,
                          height: 3,
                          decoration: BoxDecoration(
                            color: controller.genre.value == g ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}

class _TypeRail extends GetView<RankController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      color: AppColors.surface,
      child: Obx(() => ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final t in controller.types)
                GestureDetector(
                  onTap: () => controller.selectType(t),
                  child: Container(
                    color: controller.type.value == t ? Colors.white : Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 16,
                          margin: const EdgeInsets.only(right: 6),
                          color: controller.type.value == t ? AppColors.primary : Colors.transparent,
                        ),
                        Expanded(
                          child: Text(
                            t.label,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: controller.type.value == t ? FontWeight.w600 : FontWeight.w400,
                              color: controller.type.value == t ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}

class _RankList extends GetView<RankController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const LoadingView();
      if (controller.books.isEmpty) {
        return const EmptyState(icon: Icons.emoji_events_outlined, message: 'Nothing ranked here yet.');
      }
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.load,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          itemCount: controller.books.length,
          itemBuilder: (_, i) {
            final book = controller.books[i];
            return InkWell(
              onTap: () => openBook(book),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookCover(book: book, width: 64, rank: i + 1, showRating: true),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            book.synopsis,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(child: TagText(book.tags)),
                              const Icon(Icons.local_fire_department_rounded,
                                  size: 14, color: AppColors.star),
                              Text(
                                Fmt.compact(book.views),
                                style: const TextStyle(fontSize: 11, color: AppColors.star),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
