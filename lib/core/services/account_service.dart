import 'dart:math';

import 'package:get/get.dart';

import '../../config/local_storage.dart';
import '../../widgets/ui_kit.dart';
import '../api/api_client.dart';
import '../models/comment_model.dart';
import '../models/inbox_message.dart';
import '../models/user_model.dart';
import '../models/wallet_models.dart';

/// Mock account: user, wallet, bonus, vouchers, rewards, subscription, follows,
/// inbox and app settings. Everything is kept on the device through
/// [LocalStorage]. Registered once in main.dart.
class AccountService extends GetxService {
  final _s = Get.find<LocalStorage>();
  final _rand = Random();

  // ── State ──────────────────────────────────────────────────────────────────
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxInt coins = 0.obs;
  final RxInt bonus = 0.obs; // derived from [bonusRecords]
  final RxInt vouchers = 0.obs;
  final RxList<WalletTransaction> transactions = <WalletTransaction>[].obs;
  final RxList<BonusRecord> bonusRecords = <BonusRecord>[].obs;
  final RxList<VoucherRecord> voucherHistory = <VoucherRecord>[].obs;
  final RxList<InboxMessage> inbox = <InboxMessage>[].obs;
  final RxList<CommentModel> myComments = <CommentModel>[].obs;
  final RxSet<String> following = <String>{}.obs; // author names

  /// Votes this reader has given each book (bookId → votes).
  final RxMap<String, int> bookVotes = <String, int>{}.obs;
  final RxSet<String> autoUnlockBooks = <String>{}.obs;
  final Rxn<DateTime> plusUntil = Rxn<DateTime>();

  // Rewards
  final RxInt checkInStreak = 0.obs;
  final Rxn<DateTime> lastCheckIn = Rxn<DateTime>();
  final RxMap<String, int> dailyTasks = <String, int>{}.obs; // resets daily
  final RxSet<String> oneTimeTasks = <String>{}.obs;
  final RxInt readingMinutesToday = 0.obs;

  // Settings
  final RxString language = 'English'.obs;
  final RxMap<String, bool> push = <String, bool>{'all': true, 'chapters': true, 'activities': true}.obs;
  final RxDouble cacheMb = 23.3.obs;

  bool get isLoggedIn => user.value != null;
  bool get isPlus => plusUntil.value?.isAfter(DateTime.now()) ?? false;
  bool get checkedInToday => lastCheckIn.value != null && _sameDay(lastCheckIn.value!, DateTime.now());

  /// Days already ticked in the current 7-day cycle. Resets after a missed
  /// day or once a full week has been collected.
  int get activeStreak {
    if (checkedInToday) return checkInStreak.value;
    final last = lastCheckIn.value;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (last == null || !_sameDay(last, yesterday) || checkInStreak.value >= 7) return 0;
    return checkInStreak.value;
  }

  int get unreadCount => inbox.where((m) => !m.read).length;

  // ── Init / persistence ─────────────────────────────────────────────────────
  Future<AccountService> init() async {
    final u = _s.read<Map>('user');
    user.value = u == null ? null : UserModel.fromJson(u);
    coins.value = _s.read<int>('coins') ?? 0;
    vouchers.value = _s.read<int>('gems') /* key kept from the gems era */ ?? 0;
    transactions.assignAll(_list('transactions', WalletTransaction.fromJson));
    bonusRecords.assignAll(_list('bonus_records', BonusRecord.fromJson));
    voucherHistory.assignAll(_list('gem_history', VoucherRecord.fromJson));
    inbox.assignAll(_list('inbox', InboxMessage.fromJson));
    myComments.assignAll(_list('my_comments', CommentModel.fromJson));
    following.assignAll(_strings('following'));
    final votes = _s.read<Map>('book_votes') ?? {};
    bookVotes.assignAll(votes.map((k, v) => MapEntry(k.toString(), (v as num).toInt())));
    autoUnlockBooks.assignAll(_strings('auto_unlock'));
    oneTimeTasks.assignAll(_strings('one_time_tasks'));
    final plus = _s.read<String>('plus_until');
    plusUntil.value = plus == null ? null : DateTime.tryParse(plus);
    checkInStreak.value = _s.read<int>('checkin_streak') ?? 0;
    final last = _s.read<String>('checkin_last');
    lastCheckIn.value = last == null ? null : DateTime.tryParse(last);
    language.value = _s.read<String>('language') ?? 'English';
    readerType.value = _s.read<String>('reader_type') ?? '';
    final accounts = _s.read<Map>('accounts') ?? {};
    _accounts.addAll(accounts.map((k, v) => MapEntry(k.toString(), Map.of(v as Map))));
    lastAccount.value = _s.read<Map>('last_account');
    final p = _s.read<Map>('push');
    if (p != null) push.assignAll(p.map((k, v) => MapEntry(k.toString(), v == true)));
    _rollDay();
    _recomputeBonus();

    if (_s.read<bool>('seeded') != true && _api == null) _seed();
    if (_online) syncAccount();
    return this;
  }

  List<T> _list<T>(String key, T Function(Map) parse) =>
      (_s.read<List>(key) ?? []).whereType<Map>().map(parse).toList();

  Iterable<String> _strings(String key) => (_s.read<List>(key) ?? []).map((e) => e.toString());

  void _save() {
    _s.write('user', user.value?.toJson());
    _s.write('accounts', _accounts);
    _s.write('last_account', lastAccount.value);
    _s.write('coins', coins.value);
    _s.write('gems', vouchers.value);
    _s.write('transactions', transactions.map((t) => t.toJson()).toList());
    _s.write('bonus_records', bonusRecords.map((b) => b.toJson()).toList());
    _s.write('gem_history', voucherHistory.map((g) => g.toJson()).toList());
    _s.write('inbox', inbox.map((m) => m.toJson()).toList());
    _s.write('my_comments', myComments.map((c) => c.toJson()).toList());
    _s.write('following', following.toList());
    _s.write('book_votes', bookVotes);
    _s.write('auto_unlock', autoUnlockBooks.toList());
    _s.write('one_time_tasks', oneTimeTasks.toList());
    _s.write('plus_until', plusUntil.value?.toIso8601String());
    _s.write('checkin_streak', checkInStreak.value);
    _s.write('checkin_last', lastCheckIn.value?.toIso8601String());
    _s.write('daily_tasks', dailyTasks);
    _s.write('reading_minutes', readingMinutesToday.value);
    _s.write('language', language.value);
    _s.write('push', push);
  }

  /// First launch: a guest with a starter balance, plus a demo account so
  /// the sign-in path can be tried ([demoEmail] / [demoPassword]).
  void _seed() {
    _accounts[demoEmail] = {
      'id': '1000001',
      'name': 'Bonovela Reader',
      'password': demoPassword,
      'verified': true,
      'provider': 'email',
    };
    coins.value = 60;
    transactions.add(
      WalletTransaction(id: _id(), kind: TxKind.reward, title: 'Welcome gift', coins: 60, date: DateTime.now()),
    );
    addBonus(20, 'Welcome bonus', days: 7, save: false);
    final now = DateTime.now();
    inbox.addAll([
      InboxMessage(
        id: _id(),
        title: 'Welcome to Bonovela 💗',
        body: 'We\'ve added 60 coins and 20 bonus to your wallet. Your first 10 chapters of every novel are free.',
        date: now,
      ),
      InboxMessage(
        id: _id(),
        title: 'Daily check-in is live',
        body: 'Check in seven days in a row to collect up to 135 bonus. Find it under Earn Rewards.',
        date: now.subtract(const Duration(hours: 3)),
      ),
      InboxMessage(
        id: _id(),
        title: 'New chapter: Reborn Before the Apocalypse',
        body: 'Chapter 260 is out now. Lin\'s ninety days are running out…',
        date: now.subtract(const Duration(days: 1)),
        bookId: 'b17',
      ),
    ]);
    _s.write('seeded', true);
    _save();
  }

  String _id() => '${DateTime.now().microsecondsSinceEpoch}${_rand.nextInt(999)}';

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// Daily counters reset when the date changes.
  void _rollDay() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_s.read<String>('rewards_day') == today) {
      final t = _s.read<Map>('daily_tasks') ?? {};
      dailyTasks.assignAll(t.map((k, v) => MapEntry(k.toString(), (v as num).toInt())));
      readingMinutesToday.value = _s.read<int>('reading_minutes') ?? 0;
    } else {
      dailyTasks.clear();
      readingMinutesToday.value = 0;
      _s.write('rewards_day', today);
    }
  }

  void _recomputeBonus() {
    bonus.value = bonusRecords.fold(0, (sum, b) => sum + b.remaining);
  }

  // ── Onboarding ─────────────────────────────────────────────────────────────
  /// '' until chosen on first launch; 'female' or 'male' afterwards.
  final RxString readerType = ''.obs;

  bool get onboarded => _s.read<bool>('onboarded') == true;

  void completeOnboarding(String type) {
    readerType.value = type;
    _s.write('reader_type', type);
    _s.write('onboarded', true);
  }

  // ── Auth ───────────────────────────────────────────────────────────────────
  // With a backend (AppConstants.apiUrl) these go to /api/auth/…; the
  // in-memory accounts below are only used by sample-data builds.
  ApiClient? get _api => Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : null;

  static String _apiError(Object e) =>
      e is ApiException ? e.message : "Couldn't reach Bonovela. Check your connection.";

  /// 'Sign in or sign up': does this email have an account yet?
  Future<({bool exists, bool verified})> emailStatus(String email) async {
    final key = email.trim().toLowerCase();
    final api = _api;
    if (api == null) return (exists: hasAccount(key), verified: isVerified(key));
    final r = await api.post('auth/email-status/', {'email': key}) as Map;
    // The server doesn't send verification emails yet, so existing accounts sign in.
    return (exists: r['exists'] == true, verified: true);
  }

  /// Creates the account; with a backend the user is signed in straight away.
  /// Returns null on success, otherwise the error to show.
  Future<String?> createAccount(String email, String password) async {
    final api = _api;
    if (api == null) {
      register(email, password);
      return null;
    }
    try {
      _signedIn(await api.post('auth/register/', {'email': email.trim().toLowerCase(), 'password': password}) as Map);
      return null;
    } catch (e) {
      return _apiError(e);
    }
  }

  /// Returns null on success, otherwise the error to show.
  Future<String?> signInWithPassword(String email, String password) async {
    final api = _api;
    if (api == null) return signIn(email, password);
    try {
      final t = await api.post('auth/token/', {'email': email.trim().toLowerCase(), 'password': password}) as Map;
      api.tokens!.save(access: t['access'] as String, refresh: t['refresh'] as String?);
      _setUser(UserModel.fromApi(await api.get('auth/me/') as Map));
      return null;
    } on ApiException catch (e) {
      return e.status == 401 ? 'Incorrect email or password. Please try again.' : e.message;
    } catch (e) {
      return _apiError(e);
    }
  }

  void _signedIn(Map tokensAndUser) {
    _api!.tokens!.save(access: tokensAndUser['access'] as String, refresh: tokensAndUser['refresh'] as String?);
    _setUser(UserModel.fromApi(tokensAndUser['user'] as Map));
  }

  void _setUser(UserModel u) {
    user.value = u;
    lastAccount.value = {'email': u.email, 'name': u.name, 'provider': 'email'};
    _save();
    syncAccount();
  }

  /// Refreshes the profile from the server (role, pen name…) after launch.
  Future<void> refreshUser() async {
    final api = _api;
    if (api == null || !api.signedIn) return;
    try {
      user.value = UserModel.fromApi(await api.get('auth/me/') as Map);
      _save();
    } on ApiException catch (e) {
      if (e.status == 401) logout();
    } catch (_) {}
  }

  // ── Auth (sample data) ─────────────────────────────────────────────────────
  static const demoEmail = 'reader@bonovela.app';
  static const demoPassword = 'bonovela1';

  /// email → {id, name, password, verified, provider}. Stands in for the
  /// server's user table.
  final Map<String, Map> _accounts = {};

  /// Account last signed in on this device: {email, name, provider}. Kept
  /// after logout so the sign-in page can offer it again.
  final Rxn<Map> lastAccount = Rxn<Map>();

  bool hasAccount(String email) => _accounts.containsKey(email.trim().toLowerCase());

  bool isVerified(String email) => _accounts[email.trim().toLowerCase()]?['verified'] == true;

  /// Creates an unverified account; [verifyEmail] completes it.
  void register(String email, String password) {
    final key = email.trim().toLowerCase();
    final name = key.split('@').first;
    _accounts[key] = {
      'id': '${1000000 + _rand.nextInt(8999999)}',
      'name': name.isEmpty ? 'Reader' : name[0].toUpperCase() + name.substring(1),
      'password': password,
      'verified': false,
      'provider': 'email',
    };
    _save();
  }

  /// Simulates the user tapping Confirm in the verification email.
  void verifyEmail(String email) {
    final key = email.trim().toLowerCase();
    _accounts[key]?['verified'] = true;
    _signInAs(key);
  }

  /// Returns null on success, otherwise the error to show.
  String? signIn(String email, String password) {
    final key = email.trim().toLowerCase();
    final acc = _accounts[key];
    if (acc == null) return 'No account found for this email.';
    if (acc['password'] != password) return 'Incorrect password. Please try again.';
    if (acc['verified'] != true) return 'Please confirm your email first.';
    _signInAs(key);
    return null;
  }

  /// Facebook / Google / Apple: no password, the account is created on first use.
  void socialLogin(String provider) {
    final key = '${provider.toLowerCase()}.reader@bonovela.app';
    _accounts.putIfAbsent(
      key,
      () => {
        'id': '${1000000 + _rand.nextInt(8999999)}',
        'name': '$provider Reader',
        'password': '',
        'verified': true,
        'provider': provider,
      },
    );
    _signInAs(key);
  }

  void _signInAs(String key) {
    final acc = _accounts[key]!;
    user.value = UserModel(id: acc['id'].toString(), name: acc['name'].toString(), email: key);
    lastAccount.value = {'email': key, 'name': acc['name'], 'provider': acc['provider']};
    _save();
  }

  void forgetLastAccount() {
    lastAccount.value = null;
    _save();
  }

  void logout() {
    final wasOnline = _online;
    _api?.tokens?.clear();
    user.value = null;
    if (wasOnline) {
      // The account lives on the server; nothing of it stays on the phone.
      coins.value = vouchers.value = checkInStreak.value = readingMinutesToday.value = 0;
      plusUntil.value = lastCheckIn.value = null;
      for (final l in <RxList>[transactions, bonusRecords, voucherHistory, inbox, myComments]) {
        l.clear();
      }
      following.clear();
      dailyTasks.clear();
      oneTimeTasks.clear();
      _recomputeBonus();
    }
    _save();
  }

  void updateProfile({required String name, required String penName, required String about}) {
    final u = user.value;
    if (u == null) return;
    _api?.patch('auth/me/', {'pen_name': penName, 'about': about}).catchError((_) => null);
    user.value = u.copyWith(name: name, penName: penName, about: about);
    _accounts[u.email]?['name'] = name;
    if (lastAccount.value?['email'] == u.email) lastAccount.value = {...lastAccount.value!, 'name': name};
    _save();
  }

  Future<void> becomeAuthor() async {
    final u = user.value;
    if (u == null) return;
    final api = _api;
    if (api != null) await api.post('auth/become-author/');
    user.value = u.copyWith(isAuthor: true);
    _save();
  }

  // ── Server sync ────────────────────────────────────────────────────────────
  // With a backend the server holds the account: [syncAccount] copies wallet,
  // history, rewards, inbox and follows into the fields above, and each
  // action below also goes to the server, then re-syncs so balances and
  // rewards are the server's numbers.
  bool get _online => _api?.signedIn ?? false;

  /// Author name → user id, learned from books (follow needs the id).
  final Map<String, String> _authorIds = {};

  void rememberAuthor(String name, String id) {
    if (name.isNotEmpty && id.isNotEmpty) _authorIds[name] = id;
  }

  Future<void>? _syncing;

  Future<void> syncAccount() => _syncing ??= _syncAccount().whenComplete(() => _syncing = null);

  Future<void> _syncAccount() async {
    final api = _api;
    if (api == null || !api.signedIn) return;
    try {
      final w = await api.get('wallet/') as Map;
      coins.value = (w['coins'] as num).toInt();
      vouchers.value = (w['vouchers'] as num).toInt();
      plusUntil.value = DateTime.tryParse(w['plus_until']?.toString() ?? '');
      transactions.assignAll([
        for (final t in (await api.get('wallet/transactions/') as List).cast<Map>())
          WalletTransaction(
            id: t['id'].toString(),
            kind: TxKind.values.firstWhere((k) => _txKinds[t['kind']] == k, orElse: () => TxKind.unlock),
            title: t['title']?.toString() ?? '',
            coins: (t['coins'] as num?)?.toInt() ?? 0,
            bonusUsed: (t['bonus_used'] as num?)?.toInt() ?? 0,
            price: t['price']?.toString() ?? '',
            date: DateTime.tryParse(t['created_at']?.toString() ?? '') ?? DateTime.now(),
            bookId: t['book_id']?.toString(),
            chapter: (t['chapter'] as num?)?.toInt(),
          ),
      ]);
      bonusRecords.assignAll([
        for (final b in (await api.get('wallet/bonus/') as List).cast<Map>())
          BonusRecord(
            id: b['id'].toString(),
            source: b['source']?.toString() ?? '',
            amount: (b['amount'] as num).toInt(),
            receivedAt: DateTime.tryParse(b['received_at']?.toString() ?? '') ?? DateTime.now(),
            expiresAt: DateTime.tryParse(b['expires_at']?.toString() ?? '') ?? DateTime.now(),
            consumed: (b['amount'] as num).toInt() - ((b['remaining'] as num?)?.toInt() ?? 0),
          ),
      ]);
      _recomputeBonus();
      voucherHistory.assignAll([
        for (final v in (await api.get('wallet/vouchers/') as List).cast<Map>())
          VoucherRecord(
            v['source']?.toString() ?? '',
            (v['amount'] as num).toInt(),
            DateTime.tryParse(v['created_at']?.toString() ?? '') ?? DateTime.now(),
          ),
      ]);
      final r = await api.get('rewards/') as Map;
      final ci = r['checkin'] as Map;
      checkInStreak.value = (ci['streak'] as num).toInt();
      lastCheckIn.value = ci['checked_in_today'] == true ? DateTime.now() : null;
      dailyTasks.assignAll({
        for (final e in (r['daily_tasks'] as Map).entries) e.key.toString(): ((e.value as Map)['done'] as num).toInt(),
        for (final m in ((r['reading'] as Map)['milestones'] as List).cast<Map>())
          if (m['claimed'] == true) 'read_${m['minutes']}': 1,
      });
      oneTimeTasks.assignAll([
        for (final e in (r['one_time_tasks'] as Map).entries)
          if ((e.value as Map)['done'] == true) e.key.toString(),
      ]);
      readingMinutesToday.value = ((r['reading'] as Map)['minutes_today'] as num).toInt();
      final box = await api.get('inbox/') as Map;
      inbox.assignAll([
        for (final m in (box['messages'] as List).cast<Map>())
          InboxMessage(
            id: m['id'].toString(),
            title: m['title']?.toString() ?? '',
            body: m['body']?.toString() ?? '',
            date: DateTime.tryParse(m['date']?.toString() ?? '') ?? DateTime.now(),
            bookId: m['book_id']?.toString(),
            read: m['read'] == true,
          ),
      ]);
      final shelfRows = (await api.get('library/') as List).cast<Map>();
      final historyRows = (await api.get('history/') as List).cast<Map>();
      _s.replaceShelfAndHistory(
        [for (final b in shelfRows) b['id'].toString()],
        [
          for (final b in historyRows)
            ReadProgress(
              b['id'].toString(),
              (b['last_chapter'] as num?)?.toInt() ?? 1,
              DateTime.tryParse(b['read_at']?.toString() ?? '') ?? DateTime.now(),
            ),
        ],
      );
      for (final b in [...shelfRows, ...historyRows]) {
        rememberAuthor(b['author']?.toString() ?? '', b['author_id']?.toString() ?? '');
      }
      final follows = (await api.get('following/') as List).cast<Map>();
      for (final a in follows) {
        rememberAuthor(a['name'].toString(), a['id'].toString());
      }
      following.assignAll([for (final a in follows) a['name'].toString()]);
      _save();
    } catch (_) {
      // Offline: keep the last copy.
    }
  }

  static const _txKinds = {
    'top_up': TxKind.topUp,
    'subscription': TxKind.subscription,
    'unlock': TxKind.unlock,
    'gift': TxKind.gift,
    'reward': TxKind.reward,
  };

  /// Sends one action, shows the server's refusal if any, then re-syncs.
  Future<void> _remote(Future<void> Function(ApiClient api) call, {bool resync = true}) async {
    final api = _api;
    if (api == null || !api.signedIn) return;
    try {
      await call(api);
    } on ApiException catch (e) {
      toast("Bonovela couldn't do that", e.message);
    } catch (_) {
      toast("Couldn't reach Bonovela", 'Check your connection and try again.');
    }
    if (resync) await syncAccount();
  }

  /// Store catalogue (coin packages, Plus plans, gifts) from the server.
  Map? _store;

  Future<Map> _storeData(ApiClient api) async => _store ??= await api.get('store/') as Map;

  /// Buys coins. Returns null when credited, otherwise why not.
  Future<String?> buyCoins({required int coinAmount, required int bonusAmount, required String price}) async {
    final api = _api;
    if (api == null || !api.signedIn) {
      topUp(coinAmount: coinAmount, bonusAmount: bonusAmount, price: price);
      return null;
    }
    try {
      final packages = ((await _storeData(api))['packages'] as List).cast<Map>();
      final p = packages.firstWhereOrNull((p) => p['coins'] == coinAmount);
      if (p == null) return 'This package is no longer available.';
      await api.post('wallet/top-up/', {'package': p['id']});
      await syncAccount();
      return null;
    } on ApiException catch (e) {
      return e.status == 501 ? "In-app payments aren't set up yet. Please try again later." : e.message;
    } catch (_) {
      return "Couldn't reach Bonovela. Check your connection.";
    }
  }

  /// Starts Bonovela Plus. Returns null when active, otherwise why not.
  Future<String?> buyPlus({required String plan, required String price, required int days}) async {
    final api = _api;
    if (api == null || !api.signedIn) {
      subscribe(plan: plan, price: price, days: days);
      return null;
    }
    try {
      final plans = ((await _storeData(api))['plans'] as List).cast<Map>();
      final p = plans.firstWhereOrNull((p) => p['days'] == days) ?? plans.firstOrNull;
      if (p == null) return 'Plus is not available right now.';
      await api.post('wallet/subscribe/', {'plan': p['id']});
      await syncAccount();
      return null;
    } on ApiException catch (e) {
      return e.status == 501 ? "In-app payments aren't set up yet. Please try again later." : e.message;
    } catch (_) {
      return "Couldn't reach Bonovela. Check your connection.";
    }
  }

  /// Redeems a promo code: the bonus granted, 0 if already used, -1 if invalid.
  Future<int> redeemCode(String code) async {
    final api = _api;
    if (api == null || !api.signedIn) return redeem(code);
    try {
      final r = await api.post('wallet/redeem/', {'code': code.trim().toUpperCase()}) as Map;
      await syncAccount();
      return (r['bonus'] as num).toInt();
    } on ApiException catch (e) {
      return e.code == 'used' ? 0 : -1;
    }
  }

  // ── Wallet ─────────────────────────────────────────────────────────────────
  /// Spends bonus (soonest-expiring first), then coins. Returns false when
  /// the combined balance is short.
  bool spend(int amount, {required String title, TxKind kind = TxKind.unlock, String? bookId, int? chapter}) {
    if (coins.value + bonus.value < amount) return false;
    var left = amount;
    final usable = bonusRecords.where((b) => b.remaining > 0).toList()
      ..sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
    for (final b in usable) {
      if (left == 0) break;
      final take = min(left, b.remaining);
      b.consumed += take;
      left -= take;
    }
    final fromBonus = amount - left;
    coins.value -= left;
    bonusRecords.refresh();
    _recomputeBonus();
    transactions.insert(
      0,
      WalletTransaction(
        id: _id(),
        kind: kind,
        title: title,
        coins: -left,
        bonusUsed: fromBonus,
        date: DateTime.now(),
        bookId: bookId,
        chapter: chapter,
      ),
    );
    _save();
    return true;
  }

  void topUp({required int coinAmount, required int bonusAmount, required String price}) {
    coins.value += coinAmount;
    transactions.insert(
      0,
      WalletTransaction(
        id: _id(),
        kind: TxKind.topUp,
        title: 'Top up $coinAmount coins',
        coins: coinAmount,
        price: price,
        date: DateTime.now(),
      ),
    );
    if (bonusAmount > 0) addBonus(bonusAmount, 'Top-up bonus', days: 30, save: false);
    addVouchers(3, 'Top up', save: false);
    _save();
  }

  void addBonus(int amount, String source, {int days = 3, bool save = true}) {
    final now = DateTime.now();
    bonusRecords.insert(
      0,
      BonusRecord(
        id: _id(),
        source: source,
        amount: amount,
        receivedAt: now,
        expiresAt: now.add(Duration(days: days)),
      ),
    );
    _recomputeBonus();
    if (save) _save();
  }

  void addVouchers(int amount, String source, {bool save = true}) {
    vouchers.value += amount;
    voucherHistory.insert(0, VoucherRecord(source, amount, DateTime.now()));
    if (save) _save();
  }

  void subscribe({required String plan, required String price, required int days}) {
    final base = isPlus ? plusUntil.value! : DateTime.now();
    plusUntil.value = base.add(Duration(days: days));
    transactions.insert(
      0,
      WalletTransaction(
        id: _id(),
        kind: TxKind.subscription,
        title: 'Bonovela Plus · $plan',
        coins: 0,
        price: price,
        date: DateTime.now(),
      ),
    );
    _save();
  }

  bool isAutoUnlock(String bookId) => autoUnlockBooks.contains(bookId);

  void setAutoUnlock(String bookId, bool on) {
    on ? autoUnlockBooks.add(bookId) : autoUnlockBooks.remove(bookId);
    _save();
    _remote(
      (api) => on ? api.post('books/$bookId/auto-unlock/') : api.delete('books/$bookId/auto-unlock/'),
      resync: false,
    );
  }

  // ── Rewards ────────────────────────────────────────────────────────────────
  /// Bonus for each day of the 7-day streak.
  static const checkInRewards = [15, 20, 20, 20, 20, 20, 20];

  /// Returns the bonus granted, or 0 if already checked in today.
  int checkIn() {
    if (checkedInToday) return 0;
    final now = DateTime.now();
    final last = lastCheckIn.value;
    final yesterday = now.subtract(const Duration(days: 1));
    final continues = last != null && _sameDay(last, yesterday);
    checkInStreak.value = continues ? checkInStreak.value % 7 + 1 : 1;
    lastCheckIn.value = now;
    final reward = checkInRewards[checkInStreak.value - 1];
    addBonus(reward, 'Check-in day ${checkInStreak.value}', save: false);
    _save();
    _remote((api) => api.post('rewards/check-in/'));
    return reward;
  }

  int taskCount(String key) => dailyTasks[key] ?? 0;

  /// Repeatable daily task (watch a video, visit a page …).
  bool completeDailyTask(String key, {required int bonusAmount, required int max, required String source}) {
    if (taskCount(key) >= max) return false;
    dailyTasks[key] = taskCount(key) + 1;
    addBonus(bonusAmount, source, save: false);
    _save();
    _remote((api) => api.post('rewards/tasks/$key/'));
    return true;
  }

  /// One-off task (follow on social media …).
  bool completeOneTimeTask(String key, {required int bonusAmount, required String source}) {
    if (oneTimeTasks.contains(key)) return false;
    oneTimeTasks.add(key);
    addBonus(bonusAmount, source, save: false);
    _save();
    _remote((api) => api.post('rewards/tasks/$key/'));
    return true;
  }

  /// Called by the reader once per minute of reading.
  void addReadingMinute() {
    _rollDay();
    readingMinutesToday.value++;
    _s.write('reading_minutes', readingMinutesToday.value);
    _remote((api) => api.post('rewards/reading-time/', {'minutes': 1}), resync: false);
  }

  /// Reading-time milestones: claim once a day when [minutes] is reached.
  bool claimReading(int minutes, {required int bonusAmount, int voucherAmount = 0}) {
    final key = 'read_$minutes';
    if (readingMinutesToday.value < minutes || taskCount(key) > 0) return false;
    dailyTasks[key] = 1;
    addBonus(bonusAmount, 'Read for $minutes minutes', save: false);
    if (voucherAmount > 0) addVouchers(voucherAmount, 'Reading task', save: false);
    _save();
    _remote((api) => api.post('rewards/reading/$minutes/claim/'));
    return true;
  }

  static const _codes = {'BONOVELA': 50, 'WELCOME20': 20, 'PINKLOVE': 30};

  /// Returns the bonus granted, 0 if already used, -1 if invalid.
  int redeem(String code) {
    final c = code.trim().toUpperCase();
    final amount = _codes[c];
    if (amount == null) return -1;
    final key = 'code_$c';
    if (oneTimeTasks.contains(key)) return 0;
    oneTimeTasks.add(key);
    addBonus(amount, 'Code $c', days: 7, save: false);
    _save();
    return amount;
  }

  // ── Voting & gifts ─────────────────────────────────────────────────────────
  /// Spends [count] vouchers as votes for a book.
  bool vote(String bookId, String title, int count) {
    if (count <= 0 || vouchers.value < count) return false;
    vouchers.value -= count;
    voucherHistory.insert(0, VoucherRecord('Voted for $title', -count, DateTime.now()));
    bookVotes[bookId] = (bookVotes[bookId] ?? 0) + count;
    _save();
    _remote((api) => api.post('books/$bookId/vote/', {'count': count}));
    return true;
  }

  /// Sends a gift (paid in coins/bonus); the gift's votes go to the book.
  bool sendGift({
    required String bookId,
    required String title,
    required String gift,
    required int price,
    required int votes,
  }) {
    final ok = spend(price, title: '$gift for $title', kind: TxKind.gift, bookId: bookId);
    if (!ok) return false;
    bookVotes[bookId] = (bookVotes[bookId] ?? 0) + votes;
    _save();
    _remote((api) async {
      final items = ((await _storeData(api))['gifts'] as List).cast<Map>();
      final item = items.firstWhereOrNull((g) => g['name'] == gift);
      if (item != null) await api.post('books/$bookId/gift/', {'item': item['id']});
    });
    return true;
  }

  // ── Social ─────────────────────────────────────────────────────────────────
  bool isFollowing(String author) => following.contains(author);

  void toggleFollow(String author) {
    final on = !isFollowing(author);
    on ? following.add(author) : following.remove(author);
    _save();
    final id = _authorIds[author];
    if (id != null) {
      _remote((api) => on ? api.post('authors/$id/follow/') : api.delete('authors/$id/follow/'), resync: false);
    }
  }

  void addComment(CommentModel c) {
    myComments.insert(0, c);
    _save();
    _remote((api) => api.post('books/${c.bookId}/reviews/', {'stars': c.stars, 'text': c.text}), resync: false);
  }

  // ── Inbox ──────────────────────────────────────────────────────────────────
  void markRead(InboxMessage m) {
    m.read = true;
    inbox.refresh();
    _save();
    _remote((api) => api.post('inbox/${m.id}/'), resync: false);
  }

  void markAllRead() {
    for (final m in inbox) {
      m.read = true;
    }
    inbox.refresh();
    _save();
    _remote((api) => api.post('inbox/read-all/'), resync: false);
  }

  void deleteMessage(InboxMessage m) {
    inbox.remove(m);
    _save();
    _remote((api) => api.delete('inbox/${m.id}/'), resync: false);
  }

  // ── Settings ───────────────────────────────────────────────────────────────
  void setLanguage(String l) {
    language.value = l;
    _save();
  }

  void setPush(String key, bool on) {
    if (key == 'all') {
      push.updateAll((_, _) => on);
    } else {
      push[key] = on;
      push['all'] = push['chapters']! && push['activities']!;
    }
    _save();
  }

  void clearCache() => cacheMb.value = 0;
}
