class BankAccount {
  final String id;
  final String userId;
  final String accountNumber;
  final String accountName;
  final String accountType;
  final double balance;
  final String currency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankAccount({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.accountName,
    required this.accountType,
    required this.balance,
    required this.currency,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
    id: json['id'] as String,
    userId: json['userId'] as String,
    accountNumber: json['accountNumber'] as String,
    accountName: json['accountName'] as String,
    accountType: json['accountType'] as String,
    balance: (json['balance'] as num).toDouble(),
    currency: json['currency'] as String,
    isActive: json['isActive'] as bool? ?? true,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'accountNumber': accountNumber,
    'accountName': accountName,
    'accountType': accountType,
    'balance': balance,
    'currency': currency,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  BankAccount copyWith({
    String? id,
    String? userId,
    String? accountNumber,
    String? accountName,
    String? accountType,
    double? balance,
    String? currency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BankAccount(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountNumber: accountNumber ?? this.accountNumber,
    accountName: accountName ?? this.accountName,
    accountType: accountType ?? this.accountType,
    balance: balance ?? this.balance,
    currency: currency ?? this.currency,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
