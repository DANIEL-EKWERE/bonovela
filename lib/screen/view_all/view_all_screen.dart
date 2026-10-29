import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/book_tiles.dart';
import '../../widgets/ui_kit.dart';
import 'controller/view_all_controller.dart';

class ViewAllScreen extends GetView<ViewAllController> {
  const ViewAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: controller.title,
      background: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.books.length,
        itemBuilder: (_, i) => BookListTile(book: controller.books[i], rank: i + 1),
      ),
    );
  }
}
