class Bill {
  final String id;
  final String userId;
  final String billType;
  final String provider;
  final String accountNumber;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final bool isPaid;
  final bool isRecurring;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bill({
    required this.id,
    required this.userId,
    required this.billType,
    required this.provider,
    required this.accountNumber,
    required this.amount,
    required this.currency,
    required this.dueDate,
    this.isPaid = false,
    this.isRecurring = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
    id: json['id'] as String,
    userId: json['userId'] as String,
    billType: json['billType'] as String,
    provider: json['provider'] as String,
    accountNumber: json['accountNumber'] as String,
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String,
    dueDate: DateTime.parse(json['dueDate'] as String),
    isPaid: json['isPaid'] as bool? ?? false,
    isRecurring: json['isRecurring'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'billType': billType,
    'provider': provider,
    'accountNumber': accountNumber,
    'amount': amount,
    'currency': currency,
    'dueDate': dueDate.toIso8601String(),
    'isPaid': isPaid,
    'isRecurring': isRecurring,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  Bill copyWith({
    String? id,
    String? userId,
    String? billType,
    String? provider,
    String? accountNumber,
    double? amount,
    String? currency,
    DateTime? dueDate,
    bool? isPaid,
    bool? isRecurring,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Bill(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    billType: billType ?? this.billType,
    provider: provider ?? this.provider,
    accountNumber: accountNumber ?? this.accountNumber,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    dueDate: dueDate ?? this.dueDate,
    isPaid: isPaid ?? this.isPaid,
    isRecurring: isRecurring ?? this.isRecurring,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
