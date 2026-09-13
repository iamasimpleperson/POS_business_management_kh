class BusinessMemberModel {
  final int id;
  final int userId;
  final int businessId;
  final String role; // owner, admin, staff
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Attached user details if available
  String? username;
  String? fullName;

  BusinessMemberModel({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.role,
    this.createdAt,
    this.updatedAt,
    this.username,
    this.fullName,
  });

  factory BusinessMemberModel.fromJson(Map<String, dynamic> json) {
    return BusinessMemberModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      businessId: json['business_id'] as int? ?? 0,
      role: json['role']?.toString() ?? 'staff',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'business_id': businessId,
        'role': role,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
