class Transaction {
  final String id;
  final String userId;
  final String accountId;
  final String type;
  final String category;
  final double amount;
  final String currency;
  final String? recipient;
  final String? description;
  final String status;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.type,
    required this.category,
    required this.amount,
    required this.currency,
    this.recipient,
    this.description,
    required this.status,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    userId: json['userId'] as String,
    accountId: json['accountId'] as String,
    type: json['type'] as String,
    category: json['category'] as String,
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String,
    recipient: json['recipient'] as String?,
    description: json['description'] as String?,
    status: json['status'] as String,
    transactionDate: DateTime.parse(json['transactionDate'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'accountId': accountId,
    'type': type,
    'category': category,
    'amount': amount,
    'currency': currency,
    'recipient': recipient,
    'description': description,
    'status': status,
    'transactionDate': transactionDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  Transaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? type,
    String? category,
    double? amount,
    String? currency,
    String? recipient,
    String? description,
    String? status,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Transaction(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountId: accountId ?? this.accountId,
    type: type ?? this.type,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    recipient: recipient ?? this.recipient,
    description: description ?? this.description,
    status: status ?? this.status,
    transactionDate: transactionDate ?? this.transactionDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
