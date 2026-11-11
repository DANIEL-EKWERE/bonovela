import 'package:get/get.dart';

import '../../config/local_storage.dart';
import '../api/api_client.dart';
import '../constants/app_constants.dart';
import '../data/drama_data.dart';
import '../models/drama_model.dart';
import '../models/wallet_models.dart';
import 'account_service.dart';

/// One episode as the server describes it.
class EpisodeInfo {
  final int number;
  final int seconds;
  final bool locked;
  final String videoUrl;

  const EpisodeInfo(this.number, this.seconds, this.locked, this.videoUrl);

  factory EpisodeInfo.fromJson(Map j) => EpisodeInfo(
    (j['number'] as num).toInt(),
    (j['duration_seconds'] as num?)?.toInt() ?? 0,
    j['is_locked'] == true,
    j['video_url']?.toString() ?? '',
  );
}

/// Drama catalogue, saved list, watch progress and unlocked episodes.
/// With a backend all of it comes from /api/dramas/…; sample-data builds
/// keep it on the device.
class DramaService extends GetxService {
  final _storage = Get.find<LocalStorage>();
  AccountService get _account => Get.find<AccountService>();
  ApiClient? get _api => Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null;

  static const _kSaved = 'drama_saved';
  static const _kProgress = 'drama_progress';
  static const _kUnlocked = 'drama_unlocked';

  final RxList<DramaModel> _remote = <DramaModel>[].obs;

  List<DramaModel> get dramas => _api == null ? DramaData.dramas : _remote;

  final RxSet<String> saved = <String>{}.obs;

  /// Drama id → last watched episode.
  final RxMap<String, int> progress = <String, int>{}.obs;

  /// "dramaId:episode" keys (sample-data builds).
  final RxSet<String> unlocked = <String>{}.obs;

  /// Drama id → its episodes, from the server.
  final RxMap<String, List<EpisodeInfo>> episodes = <String, List<EpisodeInfo>>{}.obs;

  DramaService init() {
    saved.addAll((_storage.read<List>(_kSaved) ?? []).map((e) => e.toString()));
    final p = _storage.read<Map>(_kProgress) ?? {};
    progress.addAll(p.map((k, v) => MapEntry(k.toString(), (v as num).toInt())));
    unlocked.addAll((_storage.read<List>(_kUnlocked) ?? []).map((e) => e.toString()));
    if (_api != null) {
      load();
      ever(_account.user, (_) => _loadSaved());
    }
    return this;
  }

  /// Catalogue and the signed-in user's saved list.
  Future<void> load() async {
    try {
      final rows = (await _api!.get('dramas/', {'all': '1'}) as List).cast<Map>();
      _remote.assignAll(rows.map((r) => DramaModel.fromJson(Map<String, dynamic>.from(r))));
    } catch (_) {}
    await _loadSaved();
  }

  Future<void> _loadSaved() async {
    final api = _api;
    if (api == null || !api.signedIn) return;
    try {
      final rows = (await api.get('dramas/saved/') as List).cast<Map>();
      saved.assignAll(rows.map((r) => r['id'].toString()));
    } catch (_) {}
  }

  DramaModel? byId(String id) => _api == null ? DramaData.byId(id) : _remote.firstWhereOrNull((d) => d.id == id);

  /// Episodes (lock state, video) and the last one watched, from the server.
  Future<void> loadEpisodes(DramaModel d) async {
    final api = _api;
    if (api == null) return;
    try {
      final r = await api.get('dramas/${d.id}/') as Map;
      episodes[d.id] = [for (final e in (r['episodes'] as List).cast<Map>()) EpisodeInfo.fromJson(e)];
      progress[d.id] = (r['last_episode'] as num?)?.toInt() ?? progress[d.id] ?? 1;
      if (r['is_saved'] == true) saved.add(d.id);
    } catch (_) {}
  }

  EpisodeInfo? episodeInfo(DramaModel d, int episode) => episodes[d.id]?.firstWhereOrNull((e) => e.number == episode);

  bool isSaved(String id) => saved.contains(id);

  void toggleSaved(String id) {
    final on = !saved.contains(id);
    on ? saved.add(id) : saved.remove(id);
    _storage.write(_kSaved, saved.toList());
    final api = _api;
    if (api != null && api.signedIn) {
      (on ? api.post('dramas/$id/save/') : api.delete('dramas/$id/save/')).catchError((_) => null);
    }
  }

  int lastEpisode(String id) => progress[id] ?? 1;

  /// Remembers where the viewer is; with a backend this also fetches the
  /// episode (counting the play) and returns its video address.
  Future<String> recordWatch(String id, int episode) async {
    progress[id] = episode;
    _storage.write(_kProgress, Map<String, int>.from(progress));
    final api = _api;
    if (api == null) return '';
    try {
      final r = await api.get('dramas/$id/episodes/$episode/') as Map;
      _replace(id, EpisodeInfo.fromJson(r));
      return r['video_url']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  void _replace(String dramaId, EpisodeInfo info) {
    final list = [...?episodes[dramaId]];
    final i = list.indexWhere((e) => e.number == info.number);
    i >= 0 ? list[i] = info : list.add(info);
    episodes[dramaId] = list;
  }

  bool isFree(int episode) => episode <= AppConstants.freeEpisodes;

  bool canWatch(DramaModel d, int episode) {
    final info = episodeInfo(d, episode);
    if (info != null) return !info.locked;
    return isFree(episode) || _account.isPlus || unlocked.contains('${d.id}:$episode');
  }

  /// Unlocks one episode with coins/bonus. Returns false when the balance is short.
  Future<bool> unlock(DramaModel d, int episode) async {
    if (canWatch(d, episode)) return true;
    final api = _api;
    if (api != null && api.signedIn) {
      try {
        _replace(d.id, EpisodeInfo.fromJson(await api.post('dramas/${d.id}/episodes/$episode/unlock/') as Map));
        _account.syncAccount();
        return true;
      } on ApiException catch (e) {
        if (e.status == 402) return false;
        rethrow;
      }
    }
    final ok = _account.spend(AppConstants.episodePrice, title: '${d.title} · Episode $episode', kind: TxKind.unlock);
    if (ok) {
      unlocked.add('${d.id}:$episode');
      _storage.write(_kUnlocked, unlocked.toList());
    }
    return ok;
  }
}
