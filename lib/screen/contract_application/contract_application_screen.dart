import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/contract_application_controller.dart';

/// Apply for Contract, one step at a time. Same fields and order as the web.
class ContractApplicationScreen extends GetView<ContractApplicationController> {
  const ContractApplicationScreen({super.key});

  static const _titles = [
    'Personal information and identity',
    'Residential address and contact information',
    'Contract and book information',
    'Review your application',
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = controller.step.value;
      controller.version.value; // rebuild on every field change
      return PopScope(
        canPop: step == 1,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.back();
        },
        child: SubPage(
          title: 'Apply for Contract',
          body: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              Row(
                children: [
                  for (var i = 1; i <= 4; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i <= step ? AppColors.primary : AppColors.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 10, 4, 12),
                child: Text(
                  'Step $step of 4 · ${_titles[step - 1]}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              switch (step) {
                1 => const _Personal(key: ValueKey(1)),
                2 => const _Address(key: ValueKey(2)),
                3 => const _Book(key: ValueKey(3)),
                _ => const _Review(),
              },
            ],
          ),
          bottom: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.back,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(step == 1 ? 'Cancel' : 'Back'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GradientButton(
                  label: step == 4 ? 'Submit Application' : 'Next',
                  fontSize: 15,
                  loading: controller.submitting.value,
                  onTap: step == 4 ? controller.submit : controller.next,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Shared bits ──────────────────────────────────────────────────────────────
class _Heading extends StatelessWidget {
  final String text;
  final String? hint;

  const _Heading(this.text, {this.hint});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(hint!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
        ],
      ],
    ),
  );
}

/// Text field bound to one form value; shows the field's error, if any.
class _Field extends GetView<ContractApplicationController> {
  final String name;
  final String label;
  final String value;
  final void Function(String) onChanged;
  final bool required;
  final String? hint;
  final int lines;
  final TextInputType? keyboard;

  const _Field(
    this.name,
    this.label,
    this.value,
    this.onChanged, {
    this.required = true,
    this.hint,
    this.lines = 1,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      initialValue: value,
      minLines: lines,
      maxLines: lines == 1 ? 1 : lines + 6,
      keyboardType: keyboard ?? (lines > 1 ? TextInputType.multiline : null),
      onChanged: (v) {
        controller.setField((_) => onChanged(v));
        controller.errors.remove(name);
      },
      decoration: InputDecoration(
        labelText: required ? '$label *' : '$label (optional)',
        hintText: hint,
        alignLabelWithHint: lines > 1,
        errorText: controller.errors[name],
        errorMaxLines: 3,
      ),
    ),
  );
}

/// Tappable row that opens a picker; looks like a field.
class _PickerRow extends GetView<ContractApplicationController> {
  final String name;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerRow(this.name, this.label, this.value, this.onTap);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '$label *',
          errorText: controller.errors[name],
          suffixIcon: const Icon(AppIcons.caretDown, size: 18),
        ),
        isEmpty: value.isEmpty,
        child: Text(value, style: const TextStyle(fontSize: 15)),
      ),
    ),
  );
}

/// Bottom sheet with a search box over [options] (label, value).
Future<void> _searchSheet(
  BuildContext context, {
  required String title,
  required List<(String, String)> options,
  required void Function(String value) onPick,
}) {
  final query = ''.obs;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) => SizedBox(
      height: MediaQuery.sizeOf(ctx).height * 0.8,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                onChanged: (v) => query.value = v.trim().toLowerCase(),
                decoration: const InputDecoration(hintText: 'Search', prefixIcon: Icon(AppIcons.search)),
              ),
            ),
            Expanded(
              child: Obx(() {
                final shown = options.where((o) => o.$1.toLowerCase().contains(query.value)).toList();
                return ListView.builder(
                  itemCount: shown.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(shown[i].$1),
                    onTap: () {
                      onPick(shown[i].$2);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Step 1 ───────────────────────────────────────────────────────────────────
class _Personal extends GetView<ContractApplicationController> {
  const _Personal({super.key});

  @override
  Widget build(BuildContext context) {
    final a = controller.app;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Heading('Legal name'),
              _Field('first_name', 'First Name', a.firstName, (v) => a.firstName = v),
              _Field('middle_name', 'Middle Name', a.middleName, (v) => a.middleName = v, required: false),
              _Field('surname', 'Surname', a.surname, (v) => a.surname = v),
            ],
          ),
        ),
        WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Heading('Government ID verification'),
              const _IdSide(
                front: true,
                title: 'Front of ID',
                help:
                    "Take a clear, readable photo of the front of your government-issued ID (passport, national "
                    "ID card or driver's licence). Lay it flat in good light, fill the frame, and make sure all "
                    'text and your photo are sharp, with no glare.',
              ),
              if (a.idFrontPath.isNotEmpty)
                const _IdSide(
                  front: false,
                  title: 'Back of ID',
                  help: 'Now the back of the same ID. Same tips: flat, well lit, every line readable.',
                ),
            ],
          ),
        ),
        WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Heading('Social media', hint: 'Optional. You can continue without either account.'),
              _Field(
                'facebook_url',
                'Facebook Profile Link',
                a.facebookUrl,
                (v) => a.facebookUrl = v,
                required: false,
                hint: 'https://facebook.com/…',
                keyboard: TextInputType.url,
              ),
              _Field(
                'instagram_url',
                'Instagram Profile Link',
                a.instagramUrl,
                (v) => a.instagramUrl = v,
                required: false,
                hint: 'https://instagram.com/…',
                keyboard: TextInputType.url,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IdSide extends GetView<ContractApplicationController> {
  final bool front;
  final String title;
  final String help;

  const _IdSide({required this.front, required this.title, required this.help});

  @override
  Widget build(BuildContext context) {
    final path = front ? controller.app.idFrontPath : controller.app.idBackPath;
    final error = controller.errors[front ? 'id_front' : 'id_back'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title *', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(help, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: error == null ? AppColors.divider : AppColors.error, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                if (path.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(path), height: 180, fit: BoxFit.contain),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.pickId(front: front, camera: true),
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                        label: Text(path.isEmpty ? 'Take photo' : 'Retake'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.pickId(front: front, camera: false),
                        icon: const Icon(AppIcons.upload, size: 18),
                        label: const Text('Upload'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(error, style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

// ── Step 2 ───────────────────────────────────────────────────────────────────
class _Address extends GetView<ContractApplicationController> {
  const _Address({super.key});

  @override
  Widget build(BuildContext context) {
    final a = controller.app;
    final country = controller.country;
    return Column(
      children: [
        WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Heading('Residential address', hint: 'Your real home address.'),
              _Field('house_address', 'House Address', a.houseAddress, (v) => a.houseAddress = v),
              _Field('street_name', 'Street Name', a.streetName, (v) => a.streetName = v),
              _Field('house_number', 'House Number', a.houseNumber, (v) => a.houseNumber = v),
              _PickerRow('country', 'Country', country?.name ?? '', () {
                _searchSheet(
                  context,
                  title: 'Country',
                  options: [for (final c in controller.countries) (c.name, c.code)],
                  onPick: (code) {
                    controller.chooseCountry(controller.countries.firstWhere((c) => c.code == code));
                    controller.errors.remove('country');
                  },
                );
              }),
              if (country == null || country.states.isNotEmpty)
                _PickerRow('state', 'State', controller.stateName, () {
                  if (country == null) return toast('Choose your country first');
                  _searchSheet(
                    context,
                    title: 'State',
                    options: [for (final s in country.states) (s.$2, s.$1)],
                    onPick: (code) {
                      controller.setField((a) => a.state = code);
                      controller.errors.remove('state');
                    },
                  );
                }),
              const Text('Phone Number *', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 104,
                    child: _PickerRow('phone_dial', 'Code', a.phoneDial, () {
                      _searchSheet(
                        context,
                        title: 'Country code',
                        options: [
                          for (final c in controller.countries)
                            if (c.dial.isNotEmpty) ('${c.name} ${c.dial}', c.dial),
                        ],
                        onPick: (dial) => controller.setField((a) => a.phoneDial = dial),
                      );
                    }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                      'phone_number',
                      'Number',
                      a.phoneNumber,
                      (v) => a.phoneNumber = v,
                      keyboard: TextInputType.phone,
                      hint: '801 234 5678',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                value: a.isMinor,
                onChanged: (v) => controller.setField((a) => a.isMinor = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text('Are you under 18 years old?', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Tick if yes.'),
              ),
              if (a.isMinor) ...[
                const SizedBox(height: 8),
                const _Heading('Parent or guardian', hint: "Authors under 18 need a parent or guardian's details."),
                _Field('guardian_name', "Parent's or Guardian's Full Name", a.guardianName, (v) => a.guardianName = v),
                _Field(
                  'guardian_phone',
                  "Parent's or Guardian's Phone Number",
                  a.guardianPhone,
                  (v) => a.guardianPhone = v,
                  keyboard: TextInputType.phone,
                  hint: '+234 801 234 5678',
                ),
                _Field(
                  'guardian_email',
                  "Parent's or Guardian's Email Address",
                  a.guardianEmail,
                  (v) => a.guardianEmail = v,
                  keyboard: TextInputType.emailAddress,
                ),
                _Field(
                  'guardian_address',
                  "Parent's or Guardian's Residential Address",
                  a.guardianAddress,
                  (v) => a.guardianAddress = v,
                ),
                _Field(
                  'guardian_relationship',
                  'Relationship to the Author',
                  a.guardianRelationship,
                  (v) => a.guardianRelationship = v,
                  lines: 3,
                  hint: 'e.g. She is my mother and lives with me.',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Step 3 ───────────────────────────────────────────────────────────────────
class _Book extends GetView<ContractApplicationController> {
  const _Book({super.key});

  @override
  Widget build(BuildContext context) {
    final a = controller.app;
    final desk = controller.story.isShort ? 'Short Stories' : 'Long Story';
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading('Contract Type'),
          const Row(
            children: [
              Icon(Icons.radio_button_checked, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Non-Exclusive Contract', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          if (controller.editors.isEmpty)
            Text(
              'No $desk editors are available right now. Please try again later.',
              style: const TextStyle(color: AppColors.error),
            )
          else
            _PickerRow('chosen_editor', 'Choose Editor ($desk)', controller.editorName, () {
              _searchSheet(
                context,
                title: 'Choose a $desk editor',
                options: [for (final e in controller.editors) (e.$2, e.$1)],
                onPick: (id) {
                  controller.setField((a) => a.editorId = id);
                  controller.errors.remove('chosen_editor');
                },
              );
            }),
          const SizedBox(height: 6),
          _Field(
            'character_details',
            'Character Details',
            a.characterDetails,
            (v) => a.characterDetails = v,
            lines: 6,
            hint: 'Main characters: names, ages, personalities, and how they relate.',
          ),
          _Field(
            'outline',
            'Book Outline',
            a.outline,
            (v) => a.outline = v,
            lines: 8,
            hint: 'How the story begins, develops and ends.',
          ),
        ],
      ),
    );
  }
}

// ── Step 4 ───────────────────────────────────────────────────────────────────
class _Review extends GetView<ContractApplicationController> {
  const _Review();

  @override
  Widget build(BuildContext context) {
    final a = controller.app;
    final country = controller.country;
    Widget section(String title, int step, List<(String, String)> rows, {Widget? extra}) => WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              TextButton(onPressed: () => controller.edit(step), child: const Text('Edit')),
            ],
          ),
          ?extra,
          for (final (k, v) in rows)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (k.isNotEmpty) Text(k, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(v.trim().isEmpty ? '—' : v.trim(), style: const TextStyle(fontSize: 14, height: 1.4)),
                ],
              ),
            ),
        ],
      ),
    );
    Widget photo(String path) => Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(path), height: 110, fit: BoxFit.cover),
      ),
    );
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Check everything below. Tap Edit to change a section.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        section('Personal Information', 1, [
          ('First Name', a.firstName),
          ('Middle Name', a.middleName),
          ('Surname', a.surname),
        ]),
        section(
          'Government ID – Front and Back',
          1,
          [],
          extra: Row(children: [photo(a.idFrontPath), const SizedBox(width: 8), photo(a.idBackPath)]),
        ),
        section('Social Media Links', 1, [('Facebook', a.facebookUrl), ('Instagram', a.instagramUrl)]),
        section('Residential Address', 2, [
          ('House Address', a.houseAddress),
          ('Street Name', a.streetName),
          ('House Number', a.houseNumber),
          ('Country', country?.name ?? ''),
          if (country?.states.isNotEmpty ?? false) ('State', controller.stateName),
        ]),
        section('Contact Information', 2, [('Phone Number', '${a.phoneDial} ${a.phoneNumber}')]),
        if (a.isMinor)
          section('Parent/Guardian Information', 2, [
            ('Full Name', a.guardianName),
            ('Phone', a.guardianPhone),
            ('Email', a.guardianEmail),
            ('Address', a.guardianAddress),
            ('Relationship', a.guardianRelationship),
          ]),
        section('Contract Type', 3, [('Contract', 'Non-Exclusive Contract'), ('Editor', controller.editorName)]),
        section('Character Details', 3, [('', a.characterDetails)]),
        section('Book Outline', 3, [('', a.outline)]),
        Obx(
          () => CheckboxListTile(
            value: controller.confirmed.value,
            onChanged: (v) => controller.confirmed.value = v ?? false,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            title: Text(
              'I confirm that the information I have provided is true and correct, and that the ID belongs to me'
              '${a.isMinor ? ' or my parent/guardian has agreed to this application' : ''}.',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
