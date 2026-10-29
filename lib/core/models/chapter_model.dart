class ChapterModel {
  final String id;
  final String bookId;
  final int number;
  final String title;
  final String content;
  final bool isLocked;
  final int coinPrice;

  const ChapterModel({
    required this.id,
    required this.bookId,
    required this.number,
    required this.title,
    this.content = '',
    this.isLocked = false,
    this.coinPrice = 0,
  });

  ChapterModel copyWith({String? content, bool? isLocked}) => ChapterModel(
        id: id,
        bookId: bookId,
        number: number,
        title: title,
        content: content ?? this.content,
        isLocked: isLocked ?? this.isLocked,
        coinPrice: coinPrice,
      );

  factory ChapterModel.fromJson(Map<String, dynamic> j) => ChapterModel(
        id: j['id'].toString(),
        bookId: j['book_id'].toString(),
        number: (j['number'] as num?)?.toInt() ?? 0,
        title: j['title']?.toString() ?? '',
        content: j['content']?.toString() ?? '',
        isLocked: j['is_locked'] == true,
        coinPrice: (j['coin_price'] as num?)?.toInt() ?? 0,
      );
}
