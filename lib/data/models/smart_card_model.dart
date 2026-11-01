class SmartCardModel {
  final int id;
  final String name;
  final String slug;
  final String? title;
  final String companyName;
  final String? bio;
  final String? avatar;
  final String? coverImage;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? website;
  final String? location;
  final String? googleMapsUrl;
  final Map<String, dynamic> socialLinks;
  final List<dynamic> featuredProducts;
  final int viewsCount;
  final int vcardDownloadsCount;
  final int leadsCount;
  bool isActive;
  final String publicUrl;
  final String ndefUri;
  final String vcardUrl;

  SmartCardModel({
    required this.id,
    required this.name,
    required this.slug,
    this.title,
    required this.companyName,
    this.bio,
    this.avatar,
    this.coverImage,
    this.phone,
    this.whatsapp,
    this.email,
    this.website,
    this.location,
    this.googleMapsUrl,
    required this.socialLinks,
    required this.featuredProducts,
    required this.viewsCount,
    required this.vcardDownloadsCount,
    required this.leadsCount,
    required this.isActive,
    required this.publicUrl,
    required this.ndefUri,
    required this.vcardUrl,
  });

  factory SmartCardModel.fromJson(Map<String, dynamic> json) {
    return SmartCardModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String?,
      companyName: json['company_name'] as String? ?? 'Access',
      bio: json['bio'] as String?,
      avatar: json['avatar'] as String?,
      coverImage: json['cover_image'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
      socialLinks: (json['social_links'] is Map) ? Map<String, dynamic>.from(json['social_links']) : {},
      featuredProducts: (json['featured_products'] is List) ? List<dynamic>.from(json['featured_products']) : [],
      viewsCount: json['views_count'] as int? ?? 0,
      vcardDownloadsCount: json['vcard_downloads_count'] as int? ?? 0,
      leadsCount: json['leads_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      publicUrl: json['public_url'] as String? ?? '',
      ndefUri: json['ndef_uri'] as String? ?? (json['public_url'] as String? ?? ''),
      vcardUrl: json['vcard_url'] as String? ?? '',
    );
  }
}
