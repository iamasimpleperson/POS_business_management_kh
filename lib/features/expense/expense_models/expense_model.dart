class ExpenseCategoryModel {
  final int id;
  final int businessId;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExpenseCategoryModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: json['id'] as int? ?? 0,
      businessId: json['business_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
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
        'name': name,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class ExpenseModel {
  final int id;
  final int businessId;
  final int? categoryId;
  final String title;
  final double amount;
  final DateTime? expenseDate;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExpenseModel({
    required this.id,
    required this.businessId,
    this.categoryId,
    required this.title,
    required this.amount,
    this.expenseDate,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int? ?? 0,
      businessId: json['business_id'] as int? ?? 0,
      categoryId: json['category_id'] as int?,
      title: json['title'] as String? ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      expenseDate: json['expense_date'] != null
          ? DateTime.tryParse(json['expense_date'].toString())
          : null,
      note: json['note'] as String?,
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
        'category_id': categoryId,
        'title': title,
        'amount': amount.toStringAsFixed(2),
        'expense_date': expenseDate?.toIso8601String(),
        'note': note,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
