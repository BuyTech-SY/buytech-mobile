class LeadModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? company;
  final String? notes;
  final String? cardName;
  final DateTime? createdAt;

  LeadModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.company,
    this.notes,
    this.cardName,
    this.createdAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'عميل',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      company: json['company'] as String?,
      notes: json['notes'] as String?,
      cardName: json['smart_card']?['name'] as String? ?? 'Access',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}
