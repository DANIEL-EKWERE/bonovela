import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  final String? code;

  const ApiException(this.status, this.message, {this.code});

  @override
  String toString() => message;
}

/// Thin JSON client for the Bonovela backend (`/api/...`).
class ApiClient {
  final String baseUrl;
  final http.Client _http;

  /// Bearer token once the user signs in; null browses anonymously.
  String? Function() token;

  ApiClient({String? baseUrl, http.Client? client, String? Function()? token})
    : baseUrl = (baseUrl ?? AppConstants.apiUrl).replaceAll(RegExp(r'/+$'), ''),
      _http = client ?? http.Client(),
      token = token ?? (() => null);

  static const _timeout = Duration(seconds: 20);

  Uri _uri(String path, [Map<String, String>? query]) {
    final params = {...?query}..removeWhere((_, v) => v.isEmpty);
    return Uri.parse('$baseUrl/api/$path').replace(queryParameters: params.isEmpty ? null : params);
  }

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token() != null) 'Authorization': 'Bearer ${token()}',
  };

  Future<dynamic> get(String path, [Map<String, String>? query]) async =>
      _decode(await _http.get(_uri(path, query), headers: _headers).timeout(_timeout));

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async => _decode(
    await _http.post(_uri(path), headers: _headers, body: body == null ? null : jsonEncode(body)).timeout(_timeout),
  );

  dynamic _decode(http.Response r) {
    final body = r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    final detail = body is Map ? body['detail']?.toString() : null;
    throw ApiException(r.statusCode, detail ?? 'Something went wrong (${r.statusCode}).',
        code: body is Map ? body['code']?.toString() : null);
  }

  /// DRF list endpoints are paginated: {"results": [...]}.
  static List<Map<String, dynamic>> rows(dynamic data) =>
      ((data is Map ? data['results'] : data) as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
}
