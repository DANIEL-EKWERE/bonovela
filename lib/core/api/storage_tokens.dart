import '../../config/local_storage.dart';
import 'api_client.dart';

/// JWTs kept in device storage, so the user stays signed in between launches.
class StorageTokens implements TokenStore {
  final LocalStorage _s;

  StorageTokens(this._s);

  @override
  String? get access => _s.read<String>('auth_access');

  @override
  String? get refresh => _s.read<String>('auth_refresh');

  @override
  void save({required String access, String? refresh}) {
    _s.write('auth_access', access);
    if (refresh != null) _s.write('auth_refresh', refresh);
  }

  @override
  void clear() {
    _s.remove('auth_access');
    _s.remove('auth_refresh');
  }
}
