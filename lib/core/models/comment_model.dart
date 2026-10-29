class CommentModel {
  final String id;
  final String bookId;
  final String userName;
  final int stars; // 1–5
  final String text;
  final DateTime date;
  final int likes;
  final bool isMine;

  const CommentModel({
    required this.id,
    required this.bookId,
    required this.userName,
    required this.stars,
    required this.text,
    required this.date,
    this.likes = 0,
    this.isMine = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'userName': userName,
        'stars': stars,
        'text': text,
        'date': date.toIso8601String(),
        'likes': likes,
        'isMine': isMine,
      };

  factory CommentModel.fromJson(Map j) => CommentModel(
        id: j['id'].toString(),
        bookId: j['bookId'].toString(),
        userName: j['userName']?.toString() ?? '',
        stars: (j['stars'] as num?)?.toInt() ?? 5,
        text: j['text']?.toString() ?? '',
        date: DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
        likes: (j['likes'] as num?)?.toInt() ?? 0,
        isMine: j['isMine'] == true,
      );
}
