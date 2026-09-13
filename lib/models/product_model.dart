enum ProductStatus {
  active,
  inactive;

  String toApiString() => this == ProductStatus.active ? 'ACTIVE' : 'INACTIVE';

  static ProductStatus fromString(String? status) {
    if (status?.toUpperCase() == 'INACTIVE') {
      return ProductStatus.inactive;
    }
    return ProductStatus.active;
  }
}

enum MovementType {
  inType,
  outType,
  adjust,
  returnType;

  String toApiString() {
    switch (this) {
      case MovementType.inType:
        return 'IN';
      case MovementType.outType:
        return 'OUT';
      case MovementType.adjust:
        return 'ADJUST';
      case MovementType.returnType:
        return 'RETURN';
    }
  }

  static MovementType fromString(String? type) {
    switch (type?.toUpperCase()) {
      case 'IN':
        return MovementType.inType;
      case 'OUT':
        return MovementType.outType;
      case 'ADJUST':
        return MovementType.adjust;
      case 'RETURN':
        return MovementType.returnType;
      default:
        return MovementType.inType;
    }
  }
}

/// Category Model matching CategoryResponse from API
class CategoryModel {
  final int id;
  final int businessId;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      businessId: json['business_id'] is int
          ? json['business_id']
          : int.tryParse(json['business_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson({int? businessId}) {
    return {
      'name': name,
      'business_id': businessId ?? this.businessId,
    };
  }
}

/// Product Model matching ProductResponse from OpenAPI:
/// GET /api/v1/businesses/{business_id}/products
/// GET /api/v1/businesses/{business_id}/products/{product_id}
class ProductModel {
  final int id;
  final int businessId;
  final int? categoryId;
  final String name;
  final String? sku;
  final String? barcode;
  final double costPrice;
  final double sellPrice;
  final double stockQty;
  final String? unit;
  final String? image;
  final ProductStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.categoryId,
    this.sku,
    this.barcode,
    this.costPrice = 0.0,
    this.sellPrice = 0.0,
    this.stockQty = 0.0,
    this.unit,
    this.image,
    this.status = ProductStatus.active,
    this.createdAt,
    this.updatedAt,
  });

  /// Helper parser for numbers which can be String or num in FastAPI
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      businessId: json['business_id'] is int
          ? json['business_id']
          : int.tryParse(json['business_id']?.toString() ?? '0') ?? 0,
      categoryId: _parseInt(json['category_id']),
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      costPrice: _parseDouble(json['cost_price']),
      sellPrice: _parseDouble(json['sell_price']),
      stockQty: _parseDouble(json['stock_qty']),
      unit: json['unit']?.toString(),
      image: json['image']?.toString(),
      status: ProductStatus.fromString(json['status']?.toString()),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'category_id': categoryId,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'cost_price': costPrice,
      'sell_price': sellPrice,
      'stock_qty': stockQty,
      'unit': unit,
      'image': image,
      'status': status.toApiString(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  ProductModel copyWith({
    int? id,
    int? businessId,
    int? categoryId,
    String? name,
    String? sku,
    String? barcode,
    double? costPrice,
    double? sellPrice,
    double? stockQty,
    String? unit,
    String? image,
    ProductStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      costPrice: costPrice ?? this.costPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stockQty: stockQty ?? this.stockQty,
      unit: unit ?? this.unit,
      image: image ?? this.image,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Request Model for creating a product:
/// POST /api/v1/businesses/{business_id}/products
class ProductCreate {
  final String name;
  final String? sku;
  final String? barcode;
  final double costPrice;
  final double sellPrice;
  final double stockQty;
  final String? unit;
  final String? image;
  final ProductStatus status;
  final int businessId;
  final int? categoryId;

  ProductCreate({
    required this.name,
    this.sku,
    this.barcode,
    this.costPrice = 0.0,
    this.sellPrice = 0.0,
    this.stockQty = 0.0,
    this.unit,
    this.image,
    this.status = ProductStatus.active,
    this.businessId = 0,
    this.categoryId,
  });

  Map<String, dynamic> toJson({int? businessIdOverride}) {
    return {
      'name': name,
      if (sku != null && sku!.isNotEmpty) 'sku': sku,
      if (barcode != null && barcode!.isNotEmpty) 'barcode': barcode,
      'cost_price': costPrice,
      'sell_price': sellPrice,
      'stock_qty': stockQty,
      if (unit != null && unit!.isNotEmpty) 'unit': unit,
      if (image != null && image!.isNotEmpty) 'image': image,
      'status': status.toApiString(),
      'business_id': businessIdOverride ?? businessId,
      if (categoryId != null) 'category_id': categoryId,
    };
  }
}

/// Request Model for updating a product:
/// PUT /api/v1/businesses/{business_id}/products/{product_id}
class ProductUpdate {
  final String? name;
  final String? sku;
  final String? barcode;
  final double? costPrice;
  final double? sellPrice;
  final String? unit;
  final String? image;
  final ProductStatus? status;
  final int? categoryId;

  ProductUpdate({
    this.name,
    this.sku,
    this.barcode,
    this.costPrice,
    this.sellPrice,
    this.unit,
    this.image,
    this.status,
    this.categoryId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    if (name != null) map['name'] = name;
    if (sku != null) map['sku'] = sku;
    if (barcode != null) map['barcode'] = barcode;
    if (costPrice != null) map['cost_price'] = costPrice;
    if (sellPrice != null) map['sell_price'] = sellPrice;
    if (unit != null) map['unit'] = unit;
    if (image != null) map['image'] = image;
    if (status != null) map['status'] = status!.toApiString();
    if (categoryId != null) map['category_id'] = categoryId;
    return map;
  }
}

/// Stock Movement Response:
/// GET /api/v1/businesses/{business_id}/stock-movements
class StockMovementModel {
  final int id;
  final int businessId;
  final int productId;
  final MovementType type;
  final double quantity;
  final String? referenceType;
  final int? referenceId;
  final String? note;
  final DateTime? createdAt;

  StockMovementModel({
    required this.id,
    required this.businessId,
    required this.productId,
    required this.type,
    required this.quantity,
    this.referenceType,
    this.referenceId,
    this.note,
    this.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      businessId: json['business_id'] is int
          ? json['business_id']
          : int.tryParse(json['business_id']?.toString() ?? '0') ?? 0,
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      type: MovementType.fromString(json['type']?.toString()),
      quantity: json['quantity'] is num
          ? (json['quantity'] as num).toDouble()
          : double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      referenceType: json['reference_type']?.toString(),
      referenceId: json['reference_id'] != null ? int.tryParse(json['reference_id'].toString()) : null,
      note: json['note']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'product_id': productId,
      'type': type.toApiString(),
      'quantity': quantity,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'note': note,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

/// Request Model for adjusting stock:
/// POST /api/v1/businesses/{business_id}/stock-adjustments
class StockAdjustmentCreate {
  final int productId;
  final double quantity;
  final String note;

  StockAdjustmentCreate({
    required this.productId,
    required this.quantity,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'note': note,
    };
  }
}
