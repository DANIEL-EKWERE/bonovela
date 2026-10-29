import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/book_tiles.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/categories_controller.dart';

class CategoriesScreen extends GetView<CategoriesController> {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Categories',
      background: Colors.white,
      actions: [
        TextButton(
          onPressed: controller.reset,
          child: const Text('Reset', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
      body: Obx(() {
        final results = controller.results;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Column(
                  children: [
                    _FilterRow(options: controller.genres, value: controller.genre),
                    _FilterRow(options: controller.audiences, value: controller.audience),
                    _FilterRow(options: controller.statuses, value: controller.status),
                    _FilterRow(options: controller.formats, value: controller.format),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Divider()),
            if (results.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(icon: Icons.filter_alt_off_rounded, message: 'No stories match these filters.'),
              )
            else
              SliverList.builder(
                itemCount: results.length,
                itemBuilder: (_, i) => BookListTile(book: results[i]),
              ),
          ],
        );
      }),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final List<String> options;
  final RxString value;

  const _FilterRow({required this.options, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final o in options)
            GestureDetector(
              onTap: () => value.value = o,
              child: Container(
                margin: const EdgeInsets.only(right: 8, top: 5, bottom: 5),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value.value == o ? AppColors.blush : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  o,
                  style: TextStyle(
                    fontSize: 14,
                    color: value.value == o ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: value.value == o ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
