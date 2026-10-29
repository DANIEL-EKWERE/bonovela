import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/ui_kit.dart';
import 'controller/edit_profile_controller.dart';

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        );

    return SubPage(
      title: 'Edit Profile',
      background: Colors.white,
      actions: [
        IconButton(onPressed: controller.save, icon: const Icon(Icons.check_rounded, color: AppColors.primary)),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          InkWell(
            onTap: controller.uploadPicture,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.plum,
                  child: Text(controller.user.initial,
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                const Text('Upload Picture', style: TextStyle(fontSize: 15)),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
              ],
            ),
          ),
          label('Name'),
          TextField(controller: controller.name, decoration: const InputDecoration(hintText: 'Your name')),
          label('Pen name'),
          TextField(
            controller: controller.penName,
            decoration: const InputDecoration(hintText: 'Shown on stories you publish'),
          ),
          label('Email'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
            child: Text(controller.user.email, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          label('ID'),
          Text(controller.user.id, style: const TextStyle(color: AppColors.textSecondary)),
          label('About yourself'),
          TextField(
            controller: controller.about,
            maxLines: 4,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: 'A bit about yourself, personal website',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
