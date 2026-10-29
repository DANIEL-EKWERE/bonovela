class UserModel {
  final String id;
  final String name;
  final String penName;
  final String email;
  final String about;
  final bool isAuthor;
  final int followers;

  const UserModel({
    required this.id,
    required this.name,
    this.penName = '',
    this.email = '',
    this.about = '',
    this.isAuthor = false,
    this.followers = 0,
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
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'penName': penName,
        'email': email,
        'about': about,
        'isAuthor': isAuthor,
        'followers': followers,
      };

  factory UserModel.fromJson(Map j) => UserModel(
        id: j['id'].toString(),
        name: j['name']?.toString() ?? '',
        penName: j['penName']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        about: j['about']?.toString() ?? '',
        isAuthor: j['isAuthor'] == true,
        followers: (j['followers'] as num?)?.toInt() ?? 0,
      );
}
