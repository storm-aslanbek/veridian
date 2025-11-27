class User {
  final String id;
  final String firstName;
  final String surname;
  final String? patronymic;
  final String iin;
  final String email;
  final String phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.surname,
    this.patronymic,
    required this.iin,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Геттер для получения полного имени (как раньше было 'name')
  String get name => '$firstName $surname';

  // Геттер для полного ФИО
  String get fullName => '$surname $firstName ${patronymic ?? ""}';

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    surname: json['surname'] as String,
    patronymic: json['patronymic'] as String?,
    iin: json['iin'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'surname': surname,
    'patronymic': patronymic,
    'iin': iin,
    'email': email,
    'phone': phone,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}