class BankCard {
  final String id;
  final String userId;
  final String accountId;
  final String cardNumber;
  final String cardHolderName;
  final String cardType;
  final String expiryDate;
  final String cvv;
  final double spendingLimit;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankCard({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.cardNumber,
    required this.cardHolderName,
    required this.cardType,
    required this.expiryDate,
    required this.cvv,
    required this.spendingLimit,
    this.isBlocked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  factory BankCard.fromJson(Map<String, dynamic> json) => BankCard(
    id: json['id'] as String,
    userId: json['userId'] as String,
    accountId: json['accountId'] as String,
    cardNumber: json['cardNumber'] as String,
    cardHolderName: json['cardHolderName'] as String,
    cardType: json['cardType'] as String,
    expiryDate: json['expiryDate'] as String,
    cvv: json['cvv'] as String,
    spendingLimit: (json['spendingLimit'] as num).toDouble(),
    isBlocked: json['isBlocked'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'accountId': accountId,
    'cardNumber': cardNumber,
    'cardHolderName': cardHolderName,
    'cardType': cardType,
    'expiryDate': expiryDate,
    'cvv': cvv,
    'spendingLimit': spendingLimit,
    'isBlocked': isBlocked,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  BankCard copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? cardNumber,
    String? cardHolderName,
    String? cardType,
    String? expiryDate,
    String? cvv,
    double? spendingLimit,
    bool? isBlocked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BankCard(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountId: accountId ?? this.accountId,
    cardNumber: cardNumber ?? this.cardNumber,
    cardHolderName: cardHolderName ?? this.cardHolderName,
    cardType: cardType ?? this.cardType,
    expiryDate: expiryDate ?? this.expiryDate,
    cvv: cvv ?? this.cvv,
    spendingLimit: spendingLimit ?? this.spendingLimit,
    isBlocked: isBlocked ?? this.isBlocked,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
