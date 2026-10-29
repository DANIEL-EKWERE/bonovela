enum TxKind { topUp, subscription, unlock, gift, reward }

/// One coin movement. Top-ups and subscriptions show in Transaction History;
/// unlocks and gifts show in Expense Record.
class WalletTransaction {
  final String id;
  final TxKind kind;
  final String title;

  /// Coins added (+) or spent (−).
  final int coins;

  /// Bonus spent alongside coins (expenses only).
  final int bonusUsed;

  /// Real-money price, e.g. "₦1,500". Empty for non-purchases.
  final String price;
  final DateTime date;
  final String? bookId;
  final int? chapter;

  const WalletTransaction({
    required this.id,
    required this.kind,
    required this.title,
    required this.coins,
    this.bonusUsed = 0,
    this.price = '',
    required this.date,
    this.bookId,
    this.chapter,
  });

  bool get isPurchase => kind == TxKind.topUp || kind == TxKind.subscription;
  bool get isExpense => kind == TxKind.unlock || kind == TxKind.gift;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'coins': coins,
        'bonusUsed': bonusUsed,
        'price': price,
        'date': date.toIso8601String(),
        'bookId': bookId,
        'chapter': chapter,
      };

  factory WalletTransaction.fromJson(Map j) => WalletTransaction(
        id: j['id'].toString(),
        kind: TxKind.values.firstWhere((k) => k.name == j['kind'], orElse: () => TxKind.topUp),
        title: j['title']?.toString() ?? '',
        coins: (j['coins'] as num?)?.toInt() ?? 0,
        bonusUsed: (j['bonusUsed'] as num?)?.toInt() ?? 0,
        price: j['price']?.toString() ?? '',
        date: DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
        bookId: j['bookId']?.toString(),
        chapter: (j['chapter'] as num?)?.toInt(),
      );
}

/// Bonus is granted in batches that expire. Spending draws from the batch
/// that expires soonest.
class BonusRecord {
  final String id;
  final String source;
  final int amount;
  final DateTime receivedAt;
  final DateTime expiresAt;
  int consumed;

  BonusRecord({
    required this.id,
    required this.source,
    required this.amount,
    required this.receivedAt,
    required this.expiresAt,
    this.consumed = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get remaining => isExpired ? 0 : amount - consumed;
  int get expired => isExpired ? amount - consumed : 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'amount': amount,
        'receivedAt': receivedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'consumed': consumed,
      };

  factory BonusRecord.fromJson(Map j) => BonusRecord(
        id: j['id'].toString(),
        source: j['source']?.toString() ?? '',
        amount: (j['amount'] as num?)?.toInt() ?? 0,
        receivedAt: DateTime.tryParse(j['receivedAt']?.toString() ?? '') ?? DateTime.now(),
        expiresAt: DateTime.tryParse(j['expiresAt']?.toString() ?? '') ?? DateTime.now(),
        consumed: (j['consumed'] as num?)?.toInt() ?? 0,
      );
}

class GemRecord {
  final String source;
  final int amount;
  final DateTime date;

  const GemRecord(this.source, this.amount, this.date);

  Map<String, dynamic> toJson() => {'source': source, 'amount': amount, 'date': date.toIso8601String()};

  factory GemRecord.fromJson(Map j) => GemRecord(
        j['source']?.toString() ?? '',
        (j['amount'] as num?)?.toInt() ?? 0,
        DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
      );
}
