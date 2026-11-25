class UserModel {
  final String id;
  final String name;
  final String penName;
  final String email;
  final String about;
  final bool isAuthor;
  final int followers;

  /// Bonovela IDs staff search by: Reader ID (RD-100132) and, for authors,
  /// Author ID (AUT-32). Empty for accounts that exist only on this device.
  final String readerId;
  final String authorId;

  const UserModel({
    required this.id,
    required this.name,
    this.penName = '',
    this.email = '',
    this.about = '',
    this.isAuthor = false,
    this.followers = 0,
    this.readerId = '',
    this.authorId = '',
  });

  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();

  UserModel copyWith({String? name, String? penName, String? about, bool? isAuthor}) => UserModel(
    id: id,
    name: name ?? this.name,
    penName: penName ?? this.penName,
    email: email,
    about: about ?? this.about,
    isAuthor: isAuthor ?? this.isAuthor,
    followers: followers,
    readerId: readerId,
    authorId: authorId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'penName': penName,
    'email': email,
    'about': about,
    'isAuthor': isAuthor,
    'followers': followers,
    'readerId': readerId,
    'authorId': authorId,
  };

  /// From the API's user object (UserSerializer).
  factory UserModel.fromApi(Map j) => UserModel(
    id: j['id'].toString(),
    name: j['name']?.toString() ?? '',
    penName: j['pen_name']?.toString() ?? '',
    email: j['email']?.toString() ?? '',
    about: j['about']?.toString() ?? '',
    isAuthor: j['is_author'] == true,
    followers: (j['followers'] as num?)?.toInt() ?? 0,
    readerId: j['reader_id']?.toString() ?? '',
    authorId: j['author_id']?.toString() ?? '',
  );

  factory UserModel.fromJson(Map j) => UserModel(
    id: j['id'].toString(),
    name: j['name']?.toString() ?? '',
    penName: j['penName']?.toString() ?? '',
    email: j['email']?.toString() ?? '',
    about: j['about']?.toString() ?? '',
    isAuthor: j['isAuthor'] == true,
    followers: (j['followers'] as num?)?.toInt() ?? 0,
    readerId: j['readerId']?.toString() ?? '',
    authorId: j['authorId']?.toString() ?? '',
  );
}
