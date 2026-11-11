/// Apply for Contract: what the author fills in across the four steps.
/// Mirrors the backend's ContractApplicationForm (same fields and rules).
class ContractApplication {
  // Step 1 · legal name, ID, socials
  String firstName = '';
  String middleName = '';
  String surname = '';
  String idFrontPath = '';
  String idBackPath = '';
  String facebookUrl = '';
  String instagramUrl = '';

  // Step 2 · residential address and contact
  String houseAddress = '';
  String streetName = '';
  String houseNumber = '';
  String country = ''; // ISO 3166 code
  String state = ''; // ISO 3166-2 code, or '' when the country has none
  String phoneDial = '';
  String phoneNumber = '';
  bool isMinor = false;
  String guardianName = '';
  String guardianPhone = '';
  String guardianEmail = '';
  String guardianAddress = '';
  String guardianRelationship = '';

  // Step 3 · contract and book (contract type is always Non-Exclusive)
  String editorId = '';
  String characterDetails = '';
  String outline = '';

  String get legalName => [firstName, middleName, surname].where((p) => p.trim().isNotEmpty).join(' ');

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _url = RegExp(r'^https?://\S+\.\S+');
  static final _digits = RegExp(r'\d');

  /// Problems with [step] (1–3), field → message. Empty when it can continue.
  Map<String, String> errors(int step, {required bool countryHasStates}) {
    final e = <String, String>{};
    void need(String key, String value, [String msg = 'Required.']) {
      if (value.trim().isEmpty) e[key] = msg;
    }

    switch (step) {
      case 1:
        need('first_name', firstName);
        need('surname', surname);
        need('id_front', idFrontPath, 'Add a photo of the front of your ID.');
        need('id_back', idBackPath, 'Add a photo of the back of your ID.');
        for (final (key, value) in [('facebook_url', facebookUrl), ('instagram_url', instagramUrl)]) {
          if (value.trim().isNotEmpty && !_url.hasMatch(value.trim())) e[key] = 'Enter a full link, starting https://';
        }
      case 2:
        need('house_address', houseAddress);
        need('street_name', streetName);
        need('house_number', houseNumber);
        need('country', country, 'Choose your country from the list.');
        if (countryHasStates) need('state', state, 'Choose your state from the list.');
        if (_digits.allMatches(phoneNumber).length < 6) e['phone_number'] = 'Enter a valid phone number.';
        if (isMinor) {
          need('guardian_name', guardianName, 'Required for authors under 18.');
          need('guardian_address', guardianAddress, 'Required for authors under 18.');
          need('guardian_relationship', guardianRelationship, 'Required for authors under 18.');
          if (!guardianPhone.trim().startsWith('+') || _digits.allMatches(guardianPhone).length < 8) {
            e['guardian_phone'] = "Enter the guardian's number with its country code, e.g. +234…";
          }
          if (!_email.hasMatch(guardianEmail.trim())) e['guardian_email'] = 'Enter a valid email address.';
        }
      case 3:
        need('chosen_editor', editorId, 'Choose an editor.');
        need('character_details', characterDetails);
        need('outline', outline);
    }
    return e;
  }

  /// Form fields for `POST /api/author/stories/<id>/application/` (the ID
  /// photos go as files id_front / id_back).
  Map<String, String> toFields() => {
    'first_name': firstName.trim(),
    'middle_name': middleName.trim(),
    'surname': surname.trim(),
    'facebook_url': facebookUrl.trim(),
    'instagram_url': instagramUrl.trim(),
    'house_address': houseAddress.trim(),
    'street_name': streetName.trim(),
    'house_number': houseNumber.trim(),
    'country': country,
    'state': state,
    'phone_dial': phoneDial,
    'phone_number': phoneNumber.trim(),
    if (isMinor) ...{
      'is_minor': 'on',
      'guardian_name': guardianName.trim(),
      'guardian_phone': guardianPhone.trim(),
      'guardian_email': guardianEmail.trim(),
      'guardian_address': guardianAddress.trim(),
      'guardian_relationship': guardianRelationship.trim(),
    },
    'chosen_editor': editorId,
    'character_details': characterDetails.trim(),
    'outline': outline.trim(),
    'confirm': 'on',
  };
}
