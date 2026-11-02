import 'package:get/get.dart';

import '../../../config/local_storage.dart';
import '../../../widgets/ui_kit.dart';

/// Short dramas (video episodes). Not built yet — the tab shows a
/// "coming soon" page and lets readers ask to be notified.
class DramaController extends GetxController {
  final _storage = Get.find<LocalStorage>();

  static const _kNotify = 'drama_notify';

  final RxBool notify = false.obs;

  @override
  void onInit() {
    super.onInit();
    notify.value = _storage.read<bool>(_kNotify) ?? false;
  }

  void toggleNotify() {
    notify.toggle();
    _storage.write(_kNotify, notify.value);
    toast(
      notify.value ? 'We\'ll let you know' : 'Notification off',
      notify.value ? 'You\'ll get a message when Drama launches.' : '',
    );
  }
}
