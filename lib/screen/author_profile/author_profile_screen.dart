import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/book_tiles.dart';
import '../../widgets/common.dart';
import 'controller/author_profile_controller.dart';

class AuthorProfileScreen extends GetView<AuthorProfileController> {
  final String author;

  const AuthorProfileScreen({super.key, required this.author});

  @override
  String? get tag => author;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
        actions: [IconButton(onPressed: () => _showMenu(context), icon: const Icon(Icons.more_horiz_rounded))],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 170,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primaryLight, AppColors.plumLight]),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 140),
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),
              Positioned(
                top: 100,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 43,
                        backgroundColor: AppColors.plum,
                        child: Text(author[0],
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(10)),
                        child: const Text('Author',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Text(author, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 6, 32, 0),
            child: Text(controller.bio,
                textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => Row(
                  children: [
                    _Stat(value: Fmt.compact(controller.followers), label: 'Followers'),
                    _Stat(value: '${controller.books.length}', label: 'Stories'),
                    _Stat(
                      value: Fmt.compact(controller.books.fold(0, (s, b) => s + b.views)),
                      label: 'Reads',
                    ),
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Stories by $author', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          for (final b in controller.books)
            InkWell(
              onTap: () => openBook(b),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookCover(book: b, width: 76),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 3),
                          Text('${b.isCompleted ? 'Completed' : 'Ongoing'} · ${Fmt.compact(b.wordCount)} Words',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          Text(b.synopsis,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 8, 40, 12),
          child: Obx(() => controller.isFollowing
              ? OutlinedButton.icon(
                  onPressed: controller.toggleFollow,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Following'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.divider),
                    shape: const StadiumBorder(),
                  ),
                )
              : GradientButton(label: 'Follow', onTap: controller.toggleFollow)),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Report', textAlign: TextAlign.center),
                      onTap: () {
                        Get.back();
                        controller.report();
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Block', textAlign: TextAlign.center, style: TextStyle(color: AppColors.error)),
                      onTap: () {
                        Get.back();
                        controller.block();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  title: const Text('Cancel', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textHint)),
                  onTap: Get.back,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      );
}
