import '../../stock/stock_model/stock_model.dart';

class PurchaseItemCreate {
  final int productId;
  final double quantity;
  final double costPrice;

  PurchaseItemCreate({
    required this.productId,
    this.quantity = 1,
    required this.costPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'cost_price': costPrice,
    };
  }
}

class PurchaseCreate {
  final int businessId;
  final int? supplierId;
  final String? invoiceNo;
  final double paidAmount;
  final DateTime? purchaseDate;
  final List<PurchaseItemCreate> items;

  PurchaseCreate({
    this.businessId = 0,
    this.supplierId,
    this.invoiceNo,
    this.paidAmount = 0.0,
    this.purchaseDate,
    required this.items,
  });

  Map<String, dynamic> toJson({int? businessIdOverride}) {
    return {
      'business_id': businessIdOverride ?? businessId,
      if (supplierId != null && supplierId! > 0) 'supplier_id': supplierId,
      if (invoiceNo != null && invoiceNo!.isNotEmpty) 'invoice_no': invoiceNo,
      'paid_amount': paidAmount,
      'purchase_date': (purchaseDate ?? DateTime.now()).toUtc().toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class PurchaseItemResponse {
  final int id;
  final int purchaseId;
  final int? productId;
  final String? productName;
  final double quantity;
  final double costPrice;
  final double subtotal;

  PurchaseItemResponse({
    required this.id,
    required this.purchaseId,
    this.productId,
    this.productName,
    required this.quantity,
    required this.costPrice,
    required this.subtotal,
  });

  factory PurchaseItemResponse.fromJson(Map<String, dynamic> json) {
    final qty = json['quantity'] is num
        ? (json['quantity'] as num).toDouble()
        : double.tryParse(json['quantity']?.toString() ?? '1') ?? 1.0;
    final cost = json['cost_price'] is num
        ? (json['cost_price'] as num).toDouble()
        : double.tryParse(json['cost_price']?.toString() ?? '0') ?? 0.0;
    final sub = json['subtotal'] is num
        ? (json['subtotal'] as num).toDouble()
        : double.tryParse(json['subtotal']?.toString() ?? '') ?? (qty * cost);

    return PurchaseItemResponse(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      purchaseId: json['purchase_id'] is int
          ? json['purchase_id']
          : int.tryParse(json['purchase_id']?.toString() ?? '0') ?? 0,
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse(json['product_id']?.toString() ?? ''),
      productName: json['product_name']?.toString() ?? json['name']?.toString(),
      quantity: qty,
      costPrice: cost,
      subtotal: sub,
    );
  }
}

class PurchaseResponse {
  final int id;
  final int businessId;
  final int? supplierId;
  final String? supplierName;
  final String? invoiceNo;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String paymentStatus;
  final DateTime? purchaseDate;
  final DateTime? createdAt;
  final List<PurchaseItemResponse> items;

  PurchaseResponse({
    required this.id,
    required this.businessId,
    this.supplierId,
    this.supplierName,
    this.invoiceNo,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.status = 'COMPLETED',
    this.paymentStatus = 'PAID',
    this.purchaseDate,
    this.createdAt,
    this.items = const [],
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) {
    final total = json['total_amount'] is num
        ? (json['total_amount'] as num).toDouble()
        : double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0;
    final paid = json['paid_amount'] is num
        ? (json['paid_amount'] as num).toDouble()
        : double.tryParse(json['paid_amount']?.toString() ?? '0') ?? 0.0;

    return PurchaseResponse(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      businessId: json['business_id'] is int
          ? json['business_id']
          : int.tryParse(json['business_id']?.toString() ?? '0') ?? 0,
      supplierId: json['supplier_id'] is int
          ? json['supplier_id']
          : int.tryParse(json['supplier_id']?.toString() ?? ''),
      supplierName: json['supplier_name']?.toString() ?? json['supplier']?['name']?.toString(),
      invoiceNo: json['invoice_no']?.toString(),
      totalAmount: total,
      paidAmount: paid,
      status: json['status']?.toString() ?? 'COMPLETED',
      paymentStatus: json['payment_status']?.toString() ?? (paid >= total ? 'PAID' : (paid > 0 ? 'PARTIAL' : 'UNPAID')),
      purchaseDate: json['purchase_date'] != null ? DateTime.tryParse(json['purchase_date'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      items: json['items'] is List
          ? (json['items'] as List).map((i) => PurchaseItemResponse.fromJson(i as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class PurchaseCartItem {
  final ProductModel product;
  final double quantity;
  final double costPrice;

  PurchaseCartItem({
    required this.product,
    this.quantity = 1.0,
    required this.costPrice,
  });

  PurchaseCartItem copyWith({
    ProductModel? product,
    double? quantity,
    double? costPrice,
  }) {
    return PurchaseCartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice ?? this.costPrice,
    );
  }

  double get totalPrice => costPrice * quantity;
}
