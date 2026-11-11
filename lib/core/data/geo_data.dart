import 'dart:convert';

import 'package:flutter/services.dart';

class Country {
  final String code;
  final String name;
  final String dial;

  /// (code, name) of its states/regions; empty for countries without any.
  final List<(String, String)> states;

  const Country(this.code, this.name, this.dial, this.states);
}

/// Every country with its states and dialing code, bundled as
/// assets/data/geo.json. It's generated from the backend (pycountry +
/// phonenumbers, apps/editorial/geo.py) so the app and web lists match.
class GeoData {
  static List<Country>? _countries;

  static Future<List<Country>> countries() async {
    if (_countries != null) return _countries!;
    final raw = jsonDecode(await rootBundle.loadString('assets/data/geo.json')) as List;
    return _countries = [
      for (final c in raw.cast<Map>())
        Country(c['code'] as String, c['name'] as String, c['dial'] as String, [
          for (final s in (c['states'] as List).cast<List>()) (s[0] as String, s[1] as String),
        ]),
    ];
  }
}
