class TransferRecipient {
  final String id;
  final String userId;
  final String name;
  final String accountNumber;
  final String? bankName;
  final String? email;
  final String recipientType;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransferRecipient({
    required this.id,
    required this.userId,
    required this.name,
    required this.accountNumber,
    this.bankName,
    this.email,
    required this.recipientType,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransferRecipient.fromJson(Map<String, dynamic> json) => TransferRecipient(
    id: json['id'] as String,
    userId: json['userId'] as String,
    name: json['name'] as String,
    accountNumber: json['accountNumber'] as String,
    bankName: json['bankName'] as String?,
    email: json['email'] as String?,
    recipientType: json['recipientType'] as String,
    isFavorite: json['isFavorite'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'accountNumber': accountNumber,
    'bankName': bankName,
    'email': email,
    'recipientType': recipientType,
    'isFavorite': isFavorite,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  TransferRecipient copyWith({
    String? id,
    String? userId,
    String? name,
    String? accountNumber,
    String? bankName,
    String? email,
    String? recipientType,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TransferRecipient(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    accountNumber: accountNumber ?? this.accountNumber,
    bankName: bankName ?? this.bankName,
    email: email ?? this.email,
    recipientType: recipientType ?? this.recipientType,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
