class Loan {
  final String id;
  final String userId;
  final String loanType;
  final double principalAmount;
  final double interestRate;
  final int termMonths;
  final double monthlyPayment;
  final double totalPaid;
  final double remainingAmount;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? nextPaymentDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Loan({
    required this.id,
    required this.userId,
    required this.loanType,
    required this.principalAmount,
    required this.interestRate,
    required this.termMonths,
    required this.monthlyPayment,
    required this.totalPaid,
    required this.remainingAmount,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.nextPaymentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage {
    if (principalAmount == 0) return 0;
    return (totalPaid / (principalAmount + (principalAmount * interestRate * termMonths / 1200))) * 100;
  }

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id: json['id'] as String,
    userId: json['userId'] as String,
    loanType: json['loanType'] as String,
    principalAmount: (json['principalAmount'] as num).toDouble(),
    interestRate: (json['interestRate'] as num).toDouble(),
    termMonths: json['termMonths'] as int,
    monthlyPayment: (json['monthlyPayment'] as num).toDouble(),
    totalPaid: (json['totalPaid'] as num).toDouble(),
    remainingAmount: (json['remainingAmount'] as num).toDouble(),
    status: json['status'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    nextPaymentDate: json['nextPaymentDate'] != null ? DateTime.parse(json['nextPaymentDate'] as String) : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'loanType': loanType,
    'principalAmount': principalAmount,
    'interestRate': interestRate,
    'termMonths': termMonths,
    'monthlyPayment': monthlyPayment,
    'totalPaid': totalPaid,
    'remainingAmount': remainingAmount,
    'status': status,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'nextPaymentDate': nextPaymentDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  Loan copyWith({
    String? id,
    String? userId,
    String? loanType,
    double? principalAmount,
    double? interestRate,
    int? termMonths,
    double? monthlyPayment,
    double? totalPaid,
    double? remainingAmount,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextPaymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Loan(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    loanType: loanType ?? this.loanType,
    principalAmount: principalAmount ?? this.principalAmount,
    interestRate: interestRate ?? this.interestRate,
    termMonths: termMonths ?? this.termMonths,
    monthlyPayment: monthlyPayment ?? this.monthlyPayment,
    totalPaid: totalPaid ?? this.totalPaid,
    remainingAmount: remainingAmount ?? this.remainingAmount,
    status: status ?? this.status,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
