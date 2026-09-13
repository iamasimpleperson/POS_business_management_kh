class SupplierModel {
  final int id;
  final int businessId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SupplierModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      businessId: json['business_id'] is int
          ? json['business_id']
          : int.tryParse(json['business_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  String get initials {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.trim().substring(0, name.trim().length >= 2 ? 2 : 1).toUpperCase();
  }
}

class SupplierCreate {
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final int businessId;

  SupplierCreate({
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.businessId = 0,
  });

  Map<String, dynamic> toJson({int? businessIdOverride}) {
    return {
      'name': name.trim(),
      'phone': (phone != null && phone!.trim().isNotEmpty) ? phone!.trim() : null,
      'email': (email != null && email!.trim().isNotEmpty) ? email!.trim() : null,
      'address': (address != null && address!.trim().isNotEmpty) ? address!.trim() : null,
      'business_id': businessIdOverride ?? businessId,
    };
  }
}

class SupplierUpdate {
  final String? name;
  final String? phone;
  final String? email;
  final String? address;

  SupplierUpdate({
    this.name,
    this.phone,
    this.email,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    if (name != null) map['name'] = name!.trim();
    if (phone != null) {
      map['phone'] = phone!.trim().isEmpty ? null : phone!.trim();
    }
    if (email != null) {
      map['email'] = email!.trim().isEmpty ? null : email!.trim();
    }
    if (address != null) {
      map['address'] = address!.trim().isEmpty ? null : address!.trim();
    }
    return map;
  }
}

typedef Supplier = SupplierModel;
