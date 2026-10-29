import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

class EditProfileController extends GetxController {
  final _account = Get.find<AccountService>();

  late final UserModel user;
  late final TextEditingController name;
  late final TextEditingController penName;
  late final TextEditingController about;

  @override
  void onInit() {
    super.onInit();
    user = _account.user.value!;
    name = TextEditingController(text: user.name);
    penName = TextEditingController(text: user.penName);
    about = TextEditingController(text: user.about);
  }

  @override
  void onClose() {
    name.dispose();
    penName.dispose();
    about.dispose();
    super.onClose();
  }

  void uploadPicture() => toast('Photo upload', 'Picking a photo will be added with the media picker.');

  void save() {
    if (name.text.trim().isEmpty) return toast('Name can\'t be empty');
    _account.updateProfile(name: name.text.trim(), penName: penName.text.trim(), about: about.text.trim());
    Get.back();
    toast('Profile saved');
  }
}
