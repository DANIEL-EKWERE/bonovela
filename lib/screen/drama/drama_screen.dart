import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/models/drama_model.dart';
import '../../widgets/common.dart';
import '../../widgets/drama_cover.dart';
import '../main/controller/main_controller.dart';
import 'controller/drama_controller.dart';

class DramaScreen extends GetView<DramaController> {
  const DramaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: HeaderBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Text('Drama', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                ),
              ),
              SliverToBoxAdapter(
                child: _Section(
                  title: 'Popular Picks',
                  onMore: () => controller.viewAll('Popular Picks', controller.popular),
                  child: _Grid(dramas: controller.popular),
                ),
              ),
              SliverToBoxAdapter(
                child: _Section(
                  title: 'New Release',
                  onMore: () => controller.viewAll('New Release', controller.newRelease),
                  child: _PagedRows(dramas: controller.newRelease),
                ),
              ),
              SliverToBoxAdapter(
                child: _Section(
                  title: 'You May Also Like',
                  onMore: () => controller.viewAll('You May Also Like', controller.youMayLike),
                  child: const _Spotlight(),
                ),
              ),
              SliverToBoxAdapter(
                child: _Section(
                  title: 'Trending',
                  onMore: () => controller.viewAll('Trending', controller.trending),
                  child: _PagedRows(dramas: controller.trending),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(48, 8, 48, 28),
                  child: OutlinedButton(
                    onPressed: () => Get.find<MainController>().changeTab(1),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Find more stories', style: TextStyle(fontWeight: FontWeight.w600)),
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

/// Rounded white card holding one section.
class _Section extends StatelessWidget {
  final String title;
  final VoidCallback onMore;
  final Widget child;

  const _Section({required this.title, required this.onMore, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, onMore: onMore),
          child,
        ],
      ),
    );
  }
}

/// Popular Picks: two rows of three posters.
class _Grid extends GetView<DramaController> {
  final List<DramaModel> dramas;

  const _Grid({required this.dramas});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (_, box) {
          final w = (box.maxWidth - 2 * 12) / 3;
          return Wrap(
            spacing: 12,
            runSpacing: 14,
            children: [
              for (final d in dramas)
                GestureDetector(
                  onTap: () => controller.play(d),
                  child: SizedBox(
                    width: w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DramaCover(drama: d, width: w),
                        const SizedBox(height: 6),
                        Text(
                          d.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.25),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// New Release / Trending: columns of three rows, swiped sideways.
class _PagedRows extends GetView<DramaController> {
  final List<DramaModel> dramas;

  const _PagedRows({required this.dramas});

  static const _cover = 92.0;

  @override
  Widget build(BuildContext context) {
    final pages = <List<DramaModel>>[];
    for (var i = 0; i < dramas.length; i += 3) {
      pages.add(dramas.sublist(i, (i + 3).clamp(0, dramas.length)));
    }
    final width = MediaQuery.sizeOf(context).width * 0.82;
    return SizedBox(
      height: 3 * (_cover * 4 / 3 + 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pages.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, p) => SizedBox(
          width: width,
          child: Column(
            children: [
              for (final d in pages[p])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => controller.play(d),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DramaCover(drama: d, width: _cover),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                d.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.25),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                d.synopsis,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                              ),
                            ],
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

/// You May Also Like: poster carousel; the highlighted poster is larger and
/// its blurb, save button and Play button show underneath.
class _Spotlight extends GetView<DramaController> {
  const _Spotlight();

  @override
  Widget build(BuildContext context) {
    final list = controller.youMayLike;
    return Obx(() {
      final sel = controller.likeIndex.value;
      final d = list[sel];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => i == sel ? controller.play(list[i]) : controller.likeIndex.value = i,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: i == sel ? AppColors.primary : Colors.transparent, width: 2),
                    ),
                    child: DramaCover(drama: list[i], width: i == sel ? 122 : 106),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  d.synopsis,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Obx(() {
                      final saved = controller.service.isSaved(d.id);
                      return InkWell(
                        onTap: () => controller.service.toggleSaved(d.id),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                          child: Icon(
                            saved ? AppIcons.libraryAdded : AppIcons.libraryAdd,
                            color: saved ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 14),
                    Expanded(child: GradientButton(label: 'Play', height: 46, onTap: () => controller.play(d))),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
