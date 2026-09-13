import '../../stock/stock_model/stock_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;

  CartItemModel({
    required this.product,
    required this.quantity,
  });

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice {
    final price = (product.price as dynamic);
    final p = (price is num) ? price.toDouble() : 0.0;
    final qty = (quantity as dynamic);
    final q = (qty is num) ? qty.toDouble() : 1.0;
    return p * q;
  }
}

class SaleItemCreate {
  final int productId;
  final double quantity;
  final double price;
  final double discount;

  SaleItemCreate({
    required this.productId,
    this.quantity = 1,
    required this.price,
    this.discount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'discount': discount,
    };
  }
}

class SaleCreate {
  final int businessId;
  final int? customerId;
  final String? invoiceNo;
  final double discountAmount;
  final double paidAmount;
  final String paymentMethod;
  final DateTime? saleDate;
  final bool saveAsDraft;
  final List<SaleItemCreate> items;

  SaleCreate({
    this.businessId = 0,
    this.customerId,
    this.invoiceNo,
    this.discountAmount = 0.0,
    this.paidAmount = 0.0,
    this.paymentMethod = 'CASH',
    this.saleDate,
    this.saveAsDraft = false,
    required this.items,
  });

  Map<String, dynamic> toJson({int? businessIdOverride}) {
    return {
      'business_id': businessIdOverride ?? businessId,
      if (customerId != null && customerId! > 0) 'customer_id': customerId,
      if (invoiceNo != null && invoiceNo!.isNotEmpty) 'invoice_no': invoiceNo,
      'discount_amount': discountAmount,
      'paid_amount': paidAmount,
      'payment_method': paymentMethod,
      'sale_date': (saleDate ?? DateTime.now()).toUtc().toIso8601String(),
      'save_as_draft': saveAsDraft,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class SaleItemResponse {
  final int id;
  final int saleId;
  final int? productId;
  final double quantity;
  final double price;
  final double costPrice;
  final double discount;
  final double subtotal;

  SaleItemResponse({
    required this.id,
    required this.saleId,
    this.productId,
    required this.quantity,
    required this.price,
    this.costPrice = 0.0,
    this.discount = 0.0,
    required this.subtotal,
  });

  factory SaleItemResponse.fromJson(Map<String, dynamic> json) {
    return SaleItemResponse(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      saleId: json['sale_id'] is int ? json['sale_id'] : int.tryParse(json['sale_id']?.toString() ?? '0') ?? 0,
      productId: json['product_id'] is int ? json['product_id'] : int.tryParse(json['product_id']?.toString() ?? ''),
      quantity: json['quantity'] is num ? (json['quantity'] as num).toDouble() : double.tryParse(json['quantity']?.toString() ?? '1') ?? 1.0,
      price: json['price'] is num ? (json['price'] as num).toDouble() : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      costPrice: json['cost_price'] is num ? (json['cost_price'] as num).toDouble() : double.tryParse(json['cost_price']?.toString() ?? '0') ?? 0.0,
      discount: json['discount'] is num ? (json['discount'] as num).toDouble() : double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      subtotal: json['subtotal'] is num ? (json['subtotal'] as num).toDouble() : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class SaleResponse {
  final int id;
  final int businessId;
  final int? customerId;
  final String? invoiceNo;
  final double totalAmount;
  final double discountAmount;
  final double paidAmount;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final DateTime? saleDate;
  final DateTime? createdAt;
  final List<SaleItemResponse> items;

  SaleResponse({
    required this.id,
    required this.businessId,
    this.customerId,
    this.invoiceNo,
    required this.totalAmount,
    this.discountAmount = 0.0,
    this.paidAmount = 0.0,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.saleDate,
    this.createdAt,
    this.items = const [],
  });

  factory SaleResponse.fromJson(Map<String, dynamic> json) {
    return SaleResponse(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      businessId: json['business_id'] is int ? json['business_id'] : int.tryParse(json['business_id']?.toString() ?? '0') ?? 0,
      customerId: json['customer_id'] is int ? json['customer_id'] : int.tryParse(json['customer_id']?.toString() ?? ''),
      invoiceNo: json['invoice_no']?.toString(),
      totalAmount: json['total_amount'] is num ? (json['total_amount'] as num).toDouble() : double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      discountAmount: json['discount_amount'] is num ? (json['discount_amount'] as num).toDouble() : double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      paidAmount: json['paid_amount'] is num ? (json['paid_amount'] as num).toDouble() : double.tryParse(json['paid_amount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'COMPLETED',
      paymentStatus: json['payment_status']?.toString() ?? 'PAID',
      paymentMethod: json['payment_method']?.toString(),
      saleDate: json['sale_date'] != null ? DateTime.tryParse(json['sale_date'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      items: json['items'] is List
          ? (json['items'] as List).map((i) => SaleItemResponse.fromJson(i as Map<String, dynamic>)).toList()
          : [],
    );
  }
}
