import 'package:get/get.dart';

import '../../config/local_storage.dart';
import '../constants/app_constants.dart';
import '../data/drama_data.dart';
import '../models/drama_model.dart';
import '../models/wallet_models.dart';
import 'account_service.dart';

/// Drama catalogue, saved list, watch progress and unlocked episodes (mock,
/// stored on the device).
class DramaService extends GetxService {
  final _storage = Get.find<LocalStorage>();
  AccountService get _account => Get.find<AccountService>();

  static const _kSaved = 'drama_saved';
  static const _kProgress = 'drama_progress';
  static const _kUnlocked = 'drama_unlocked';

  List<DramaModel> get dramas => DramaData.dramas;

  final RxSet<String> saved = <String>{}.obs;

  /// Drama id → last watched episode.
  final RxMap<String, int> progress = <String, int>{}.obs;

  /// "dramaId:episode" keys.
  final RxSet<String> unlocked = <String>{}.obs;

  DramaService init() {
    saved.addAll((_storage.read<List>(_kSaved) ?? []).map((e) => e.toString()));
    final p = _storage.read<Map>(_kProgress) ?? {};
    progress.addAll(p.map((k, v) => MapEntry(k.toString(), (v as num).toInt())));
    unlocked.addAll((_storage.read<List>(_kUnlocked) ?? []).map((e) => e.toString()));
    return this;
  }

  DramaModel? byId(String id) => DramaData.byId(id);

  bool isSaved(String id) => saved.contains(id);

  void toggleSaved(String id) {
    saved.contains(id) ? saved.remove(id) : saved.add(id);
    _storage.write(_kSaved, saved.toList());
  }

  int lastEpisode(String id) => progress[id] ?? 1;

  void recordWatch(String id, int episode) {
    progress[id] = episode;
    _storage.write(_kProgress, Map<String, int>.from(progress));
  }

  bool isFree(int episode) => episode <= AppConstants.freeEpisodes;

  bool canWatch(DramaModel d, int episode) =>
      isFree(episode) || _account.isPlus || unlocked.contains('${d.id}:$episode');

  /// Spends coins/bonus for one episode. Returns false when the balance is short.
  bool unlock(DramaModel d, int episode) {
    if (canWatch(d, episode)) return true;
    final ok = _account.spend(AppConstants.episodePrice, title: '${d.title} · Episode $episode', kind: TxKind.unlock);
    if (ok) {
      unlocked.add('${d.id}:$episode');
      _storage.write(_kUnlocked, unlocked.toList());
    }
    return ok;
  }
}
