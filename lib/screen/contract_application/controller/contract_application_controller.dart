import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/geo_data.dart';
import '../../../core/models/author_models.dart';
import '../../../core/models/contract_application.dart';
import '../../../core/services/author_service.dart';
import '../../../widgets/ui_kit.dart';

/// Apply for Contract: 1 personal & ID · 2 address & contact · 3 contract &
/// book · 4 review & submit. Everything stays in [app] while moving between
/// steps, so nothing is lost going back.
class ContractApplicationController extends GetxController {
  final _author = Get.find<AuthorService>();

  late final AuthorStory story;
  final app = ContractApplication();

  final RxInt step = 1.obs;
  final RxMap<String, String> errors = <String, String>{}.obs;
  final RxList<Country> countries = <Country>[].obs;
  final RxBool confirmed = false.obs;
  final RxBool submitting = false.obs;

  /// Bumped on every change so the screen rebuilds (the form is a plain object).
  final RxInt version = 0.obs;

  late final List<(String, String)> editors;

  @override
  void onInit() {
    super.onInit();
    story = _author.story(Get.arguments as String)!;
    editors = _author.editorsFor(story);
    GeoData.countries().then(countries.assignAll);
  }

  void setField(void Function(ContractApplication a) change) {
    change(app);
    version.value++;
  }

  Country? get country => countries.firstWhereOrNull((c) => c.code == app.country);

  String get stateName => country?.states.firstWhereOrNull((s) => s.$1 == app.state)?.$2 ?? '';

  String get editorName => editors.firstWhereOrNull((e) => e.$1 == app.editorId)?.$2 ?? '';

  void chooseCountry(Country c) => setField((a) {
    a
      ..country = c.code
      ..state = ''
      ..phoneDial = c.dial.isNotEmpty ? c.dial : a.phoneDial;
  });

  /// Front first; the back is asked for once the front is in.
  Future<void> pickId({required bool front, required bool camera}) async {
    try {
      final file = await ImagePicker().pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 2000,
        imageQuality: 90,
      );
      if (file == null) return;
      setField((a) => front ? a.idFrontPath = file.path : a.idBackPath = file.path);
      errors.remove(front ? 'id_front' : 'id_back');
    } on PlatformException catch (e) {
      toast(
        camera ? "Couldn't open the camera" : "Couldn't open your photos",
        e.message ?? 'Allow access in Settings and try again.',
      );
    }
  }

  bool _check(int s) {
    errors.assignAll(app.errors(s, countryHasStates: (country?.states.isNotEmpty) ?? false));
    if (errors.isNotEmpty) toast('Please check the highlighted fields', errors.values.first);
    return errors.isEmpty;
  }

  void next() {
    if (_check(step.value)) step.value++;
  }

  void back() => step.value > 1 ? step.value-- : Get.back();

  void edit(int s) {
    errors.clear();
    step.value = s;
  }

  Future<void> submit() async {
    for (var s = 1; s <= 3; s++) {
      if (!_check(s)) return edit(s);
    }
    if (!confirmed.value) return toast('Tick the box to confirm your information is correct.');
    submitting.value = true;
    try {
      await _author.submitApplication(story, app);
      Get.back();
      toast('Application submitted', 'Status: Pending review. Editors usually reply within 30 business days.');
    } finally {
      submitting.value = false;
    }
  }
}
