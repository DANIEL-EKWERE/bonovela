import 'dart:math';

import 'package:get/get.dart';

import '../../config/local_storage.dart';
import '../models/comment_model.dart';
import '../models/inbox_message.dart';
import '../models/user_model.dart';
import '../models/wallet_models.dart';

/// Mock account: user, wallet, bonus, gems, rewards, subscription, follows,
/// inbox and app settings. Everything is kept on the device through
/// [LocalStorage]. Registered once in main.dart.
class AccountService extends GetxService {
  final _s = Get.find<LocalStorage>();
  final _rand = Random();

  // ── State ──────────────────────────────────────────────────────────────────
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxInt coins = 0.obs;
  final RxInt bonus = 0.obs; // derived from [bonusRecords]
  final RxInt gems = 0.obs;
  final RxList<WalletTransaction> transactions = <WalletTransaction>[].obs;
  final RxList<BonusRecord> bonusRecords = <BonusRecord>[].obs;
  final RxList<GemRecord> gemHistory = <GemRecord>[].obs;
  final RxList<InboxMessage> inbox = <InboxMessage>[].obs;
  final RxList<CommentModel> myComments = <CommentModel>[].obs;
  final RxSet<String> following = <String>{}.obs; // author names
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
    gems.value = _s.read<int>('gems') ?? 0;
    transactions.assignAll(_list('transactions', WalletTransaction.fromJson));
    bonusRecords.assignAll(_list('bonus_records', BonusRecord.fromJson));
    gemHistory.assignAll(_list('gem_history', GemRecord.fromJson));
    inbox.assignAll(_list('inbox', InboxMessage.fromJson));
    myComments.assignAll(_list('my_comments', CommentModel.fromJson));
    following.assignAll(_strings('following'));
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

    if (_s.read<bool>('seeded') != true) _seed();
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
    _s.write('gems', gems.value);
    _s.write('transactions', transactions.map((t) => t.toJson()).toList());
    _s.write('bonus_records', bonusRecords.map((b) => b.toJson()).toList());
    _s.write('gem_history', gemHistory.map((g) => g.toJson()).toList());
    _s.write('inbox', inbox.map((m) => m.toJson()).toList());
    _s.write('my_comments', myComments.map((c) => c.toJson()).toList());
    _s.write('following', following.toList());
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
    transactions.add(WalletTransaction(
      id: _id(), kind: TxKind.reward, title: 'Welcome gift', coins: 60, date: DateTime.now(),
    ));
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

  // ── Auth (mock) ────────────────────────────────────────────────────────────
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
    _accounts.putIfAbsent(key, () => {
          'id': '${1000000 + _rand.nextInt(8999999)}',
          'name': '$provider Reader',
          'password': '',
          'verified': true,
          'provider': provider,
        });
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
    user.value = null;
    _save();
  }

  void updateProfile({required String name, required String penName, required String about}) {
    final u = user.value;
    if (u == null) return;
    user.value = u.copyWith(name: name, penName: penName, about: about);
    _accounts[u.email]?['name'] = name;
    if (lastAccount.value?['email'] == u.email) lastAccount.value = {...lastAccount.value!, 'name': name};
    _save();
  }

  void becomeAuthor() {
    final u = user.value;
    if (u == null) return;
    user.value = u.copyWith(isAuthor: true);
    _save();
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
        id: _id(), kind: kind, title: title, coins: -left, bonusUsed: fromBonus,
        date: DateTime.now(), bookId: bookId, chapter: chapter,
      ),
    );
    _save();
    return true;
  }

  void topUp({required int coinAmount, required int bonusAmount, required String price}) {
    coins.value += coinAmount;
    transactions.insert(0, WalletTransaction(
      id: _id(), kind: TxKind.topUp, title: 'Top up $coinAmount coins', coins: coinAmount, price: price,
      date: DateTime.now(),
    ));
    if (bonusAmount > 0) addBonus(bonusAmount, 'Top-up bonus', days: 30, save: false);
    addGems(3, 'Top up', save: false);
    _save();
  }

  void addBonus(int amount, String source, {int days = 3, bool save = true}) {
    final now = DateTime.now();
    bonusRecords.insert(0, BonusRecord(
      id: _id(), source: source, amount: amount, receivedAt: now, expiresAt: now.add(Duration(days: days)),
    ));
    _recomputeBonus();
    if (save) _save();
  }

  void addGems(int amount, String source, {bool save = true}) {
    gems.value += amount;
    gemHistory.insert(0, GemRecord(source, amount, DateTime.now()));
    if (save) _save();
  }

  void subscribe({required String plan, required String price, required int days}) {
    final base = isPlus ? plusUntil.value! : DateTime.now();
    plusUntil.value = base.add(Duration(days: days));
    transactions.insert(0, WalletTransaction(
      id: _id(), kind: TxKind.subscription, title: 'Bonovela Plus · $plan', coins: 0, price: price,
      date: DateTime.now(),
    ));
    _save();
  }

  bool isAutoUnlock(String bookId) => autoUnlockBooks.contains(bookId);

  void setAutoUnlock(String bookId, bool on) {
    on ? autoUnlockBooks.add(bookId) : autoUnlockBooks.remove(bookId);
    _save();
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
    return reward;
  }

  int taskCount(String key) => dailyTasks[key] ?? 0;

  /// Repeatable daily task (watch a video, visit a page …).
  bool completeDailyTask(String key, {required int bonusAmount, required int max, required String source}) {
    if (taskCount(key) >= max) return false;
    dailyTasks[key] = taskCount(key) + 1;
    addBonus(bonusAmount, source, save: false);
    _save();
    return true;
  }

  /// One-off task (follow on social media …).
  bool completeOneTimeTask(String key, {required int bonusAmount, required String source}) {
    if (oneTimeTasks.contains(key)) return false;
    oneTimeTasks.add(key);
    addBonus(bonusAmount, source, save: false);
    _save();
    return true;
  }

  /// Called by the reader once per minute of reading.
  void addReadingMinute() {
    _rollDay();
    readingMinutesToday.value++;
    _s.write('reading_minutes', readingMinutesToday.value);
  }

  /// Reading-time milestones: claim once a day when [minutes] is reached.
  bool claimReading(int minutes, {required int bonusAmount, int gemAmount = 0}) {
    final key = 'read_$minutes';
    if (readingMinutesToday.value < minutes || taskCount(key) > 0) return false;
    dailyTasks[key] = 1;
    addBonus(bonusAmount, 'Read for $minutes minutes', save: false);
    if (gemAmount > 0) addGems(gemAmount, 'Reading task', save: false);
    _save();
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

  // ── Social ─────────────────────────────────────────────────────────────────
  bool isFollowing(String author) => following.contains(author);

  void toggleFollow(String author) {
    isFollowing(author) ? following.remove(author) : following.add(author);
    _save();
  }

  void addComment(CommentModel c) {
    myComments.insert(0, c);
    _save();
  }

  // ── Inbox ──────────────────────────────────────────────────────────────────
  void markRead(InboxMessage m) {
    m.read = true;
    inbox.refresh();
    _save();
  }

  void markAllRead() {
    for (final m in inbox) {
      m.read = true;
    }
    inbox.refresh();
    _save();
  }

  void deleteMessage(InboxMessage m) {
    inbox.remove(m);
    _save();
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
