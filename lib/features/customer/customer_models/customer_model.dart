class CustomerModel {
  final int id;
  final int businessId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double totalSpent;
  final DateTime? lastVisit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.totalSpent = 0.0,
    this.lastVisit,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      businessId: json['business_id'] is int
          ? json['business_id']
          : int.tryParse(json['business_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      totalSpent: json['total_spent'] is num
          ? (json['total_spent'] as num).toDouble()
          : double.tryParse(json['total_spent']?.toString() ?? '0') ?? 0.0,
      lastVisit: json['last_visit'] != null ? DateTime.tryParse(json['last_visit'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
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
      'total_spent': totalSpent,
      if (lastVisit != null) 'last_visit': lastVisit!.toIso8601String(),
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

class CustomerCreate {
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final int businessId;

  CustomerCreate({
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

class CustomerUpdate {
  final String? name;
  final String? phone;
  final String? email;
  final String? address;

  CustomerUpdate({
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

// Keep Customer alias for backwards compatibility
typedef Customer = CustomerModel;
