class InboxMessage {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String? bookId;
  bool read;

  InboxMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.bookId,
    this.read = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'date': date.toIso8601String(),
        'bookId': bookId,
        'read': read,
      };

  factory InboxMessage.fromJson(Map j) => InboxMessage(
        id: j['id'].toString(),
        title: j['title']?.toString() ?? '',
        body: j['body']?.toString() ?? '',
        date: DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
        bookId: j['bookId']?.toString(),
        read: j['read'] == true,
      );
}
