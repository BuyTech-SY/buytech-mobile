class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final int? companyId;
  final String? jobTitle;
  final String? phone;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.companyId,
    this.jobTitle,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'مستخدم',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'employee',
      avatar: json['avatar'] as String?,
      companyId: json['company_id'] as int?,
      jobTitle: json['job_title'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      'company_id': companyId,
      'job_title': jobTitle,
      'phone': phone,
    };
  }
}
