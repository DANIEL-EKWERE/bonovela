import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  final String? code;

  /// Field errors from a form/serializer: {field: [messages]}.
  final Map<String, List<String>> fields;

  const ApiException(this.status, this.message, {this.code, this.fields = const {}});

  @override
  String toString() => message;
}

/// Where the signed-in user's JWTs live (device storage in the app).
abstract class TokenStore {
  String? get access;
  String? get refresh;
  void save({required String access, String? refresh});
  void clear();
}

/// Thin JSON client for the Bonovela backend (`/api/...`). Sends the access
/// token when there is one and refreshes it once when it has expired.
class ApiClient {
  final String baseUrl;
  final http.Client _http;
  final TokenStore? tokens;

  ApiClient({String? baseUrl, http.Client? client, this.tokens})
    : baseUrl = (baseUrl ?? AppConstants.apiUrl).replaceAll(RegExp(r'/+$'), ''),
      _http = client ?? http.Client();

  static const _timeout = Duration(seconds: 20);
  static const _uploadTimeout = Duration(seconds: 120);

  bool get signedIn => tokens?.access != null;

  Uri _uri(String path, [Map<String, String>? query]) {
    final params = {...?query}..removeWhere((_, v) => v.isEmpty);
    return Uri.parse('$baseUrl/api/$path').replace(queryParameters: params.isEmpty ? null : params);
  }

  Map<String, String> _headers({bool json = true}) => {
    'Accept': 'application/json',
    if (json) 'Content-Type': 'application/json',
    if (tokens?.access != null) 'Authorization': 'Bearer ${tokens!.access}',
  };

  Future<dynamic> get(String path, [Map<String, String>? query]) =>
      _send(() => _http.get(_uri(path, query), headers: _headers()));

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) =>
      _send(() => _http.post(_uri(path), headers: _headers(), body: body == null ? null : jsonEncode(body)));

  Future<dynamic> put(String path, Map<String, dynamic> body) =>
      _send(() => _http.put(_uri(path), headers: _headers(), body: jsonEncode(body)));

  Future<dynamic> patch(String path, Map<String, dynamic> body) =>
      _send(() => _http.patch(_uri(path), headers: _headers(), body: jsonEncode(body)));

  Future<dynamic> delete(String path) => _send(() => _http.delete(_uri(path), headers: _headers()));

  /// multipart/form-data POST (or [method]): [fields] plus files as
  /// {field: local path}.
  Future<dynamic> upload(
    String path,
    Map<String, String> fields,
    Map<String, String> files, {
    String method = 'POST',
  }) => _send(() async {
    final req = http.MultipartRequest(method, _uri(path))
      ..headers.addAll(_headers(json: false))
      ..fields.addAll(fields);
    for (final e in files.entries) {
      req.files.add(await http.MultipartFile.fromPath(e.key, e.value));
    }
    return http.Response.fromStream(await _http.send(req));
  }, timeout: _uploadTimeout);

  Future<dynamic> _send(Future<http.Response> Function() request, {Duration timeout = _timeout}) async {
    var r = await request().timeout(timeout);
    if (r.statusCode == 401 && await _refresh()) r = await request().timeout(timeout);
    return _decode(r);
  }

  /// Swaps the refresh token for a new access token; signs out if it's gone.
  Future<bool> _refresh() async {
    final store = tokens;
    final refresh = store?.refresh;
    if (store == null || refresh == null) return false;
    final r = await _http
        .post(
          _uri('auth/token/refresh/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh': refresh}),
        )
        .timeout(_timeout);
    if (r.statusCode != 200) {
      store.clear();
      return false;
    }
    final body = jsonDecode(r.body) as Map;
    store.save(access: body['access'] as String, refresh: body['refresh'] as String?);
    return true;
  }

  dynamic _decode(http.Response r) {
    final body = r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    final fields = <String, List<String>>{};
    if (body is Map) {
      final errors = body['errors'] is Map ? body['errors'] as Map : body;
      for (final e in errors.entries) {
        if (e.value is List) fields[e.key.toString()] = [for (final m in e.value as List) m.toString()];
      }
    }
    final detail = body is Map ? body['detail']?.toString() : null;
    throw ApiException(
      r.statusCode,
      detail ?? (fields.isNotEmpty ? fields.values.first.first : 'Something went wrong (${r.statusCode}).'),
      code: body is Map ? body['code']?.toString() : null,
      fields: fields,
    );
  }

  /// DRF list endpoints are paginated: {"results": [...]}.
  static List<Map<String, dynamic>> rows(dynamic data) =>
      ((data is Map ? data['results'] : data) as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
}
