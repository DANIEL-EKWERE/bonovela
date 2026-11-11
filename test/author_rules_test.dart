import 'package:flutter_test/flutter_test.dart';

import 'package:bonovela/core/models/author_models.dart';
import 'package:bonovela/core/models/contract_application.dart';

void main() {
  test('chapters: drafts may be short, nothing over 2,000, publishing needs 600–2,000', () {
    expect(AuthorChapter.lengthError(599), contains('600–2,000'));
    expect(AuthorChapter.lengthError(600), isNull);
    expect(AuthorChapter.lengthError(2000), isNull);
    expect(AuthorChapter.lengthError(2001), isNotNull);
    expect(AuthorChapter.lengthError(100, publishing: false), isNull);
    expect(AuthorChapter.lengthError(2001, publishing: false), isNotNull);
  });

  test('contract application checks each step like the backend', () {
    final a = ContractApplication();
    expect(a.errors(1, countryHasStates: true).keys, containsAll(['first_name', 'surname', 'id_front', 'id_back']));
    a
      ..firstName = 'Ada'
      ..surname = 'Okafor'
      ..idFrontPath = '/f.jpg'
      ..idBackPath = '/b.jpg'
      ..instagramUrl = 'instagram';
    expect(a.errors(1, countryHasStates: true).keys, ['instagram_url']);
    a.instagramUrl = '';
    expect(a.errors(1, countryHasStates: true), isEmpty);

    a
      ..houseAddress = 'Flat 3'
      ..streetName = 'Allen Avenue'
      ..houseNumber = '12'
      ..country = 'NG'
      ..phoneDial = '+234'
      ..phoneNumber = '0801 234 5678'
      ..isMinor = true;
    expect(
      a.errors(2, countryHasStates: true).keys,
      containsAll(['state', 'guardian_name', 'guardian_phone', 'guardian_email']),
    );
    expect(a.errors(2, countryHasStates: false).containsKey('state'), isFalse);
    a.isMinor = false;
    expect(a.toFields().containsKey('is_minor'), isFalse);
    expect(a.legalName, 'Ada Okafor');
  });
}
