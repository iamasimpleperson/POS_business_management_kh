class DebtModel {
  final int id;
  final int businessId;
  final int customerId;
  final int? saleId;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime? dueDate;
  final String status; // OPEN, PAID, OVERDUE
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Customer info for rich UI display (can be enriched or attached)
  String? customerName;
  String? customerPhone;

  DebtModel({
    required this.id,
    required this.businessId,
    required this.customerId,
    this.saleId,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    this.dueDate,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.customerName,
    this.customerPhone,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as int? ?? 0,
      businessId: json['business_id'] as int? ?? 0,
      customerId: json['customer_id'] as int? ?? 0,
      saleId: json['sale_id'] as int?,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      paidAmount: double.tryParse(json['paid_amount']?.toString() ?? '0') ?? 0.0,
      remainingAmount:
          double.tryParse(json['remaining_amount']?.toString() ?? '0') ?? 0.0,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      status: json['status']?.toString() ?? 'OPEN',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'customer_id': customerId,
        'sale_id': saleId,
        'total_amount': totalAmount.toStringAsFixed(2),
        'paid_amount': paidAmount.toStringAsFixed(2),
        'remaining_amount': remainingAmount.toStringAsFixed(2),
        'due_date': dueDate?.toIso8601String(),
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class DebtPaymentModel {
  final int id;
  final int debtId;
  final double amount;
  final String paymentMethod;
  final DateTime? paymentDate;
  final String? note;
  final DateTime? createdAt;

  DebtPaymentModel({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.paymentMethod,
    this.paymentDate,
    this.note,
    this.createdAt,
  });

  factory DebtPaymentModel.fromJson(Map<String, dynamic> json) {
    return DebtPaymentModel(
      id: json['id'] as int? ?? 0,
      debtId: json['debt_id'] as int? ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['payment_method']?.toString() ?? 'CASH',
      paymentDate: json['payment_date'] != null
          ? DateTime.tryParse(json['payment_date'].toString())
          : null,
      note: json['note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'debt_id': debtId,
        'amount': amount.toStringAsFixed(2),
        'payment_method': paymentMethod,
        'payment_date': paymentDate?.toIso8601String(),
        'note': note,
        'created_at': createdAt?.toIso8601String(),
      };
}
