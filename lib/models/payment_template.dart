class PaymentTemplate {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String? recipientId;
  final double? amount;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentTemplate({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.recipientId,
    this.amount,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentTemplate.fromJson(Map<String, dynamic> json) => PaymentTemplate(
    id: json['id'] as String,
    userId: json['userId'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    recipientId: json['recipientId'] as String?,
    amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
    description: json['description'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'category': category,
    'recipientId': recipientId,
    'amount': amount,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  PaymentTemplate copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? recipientId,
    double? amount,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PaymentTemplate(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    category: category ?? this.category,
    recipientId: recipientId ?? this.recipientId,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
