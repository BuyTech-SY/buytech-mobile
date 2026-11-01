import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/smart_card_model.dart';
import '../models/lead_model.dart';
import '../models/product_model.dart';
import 'storage_service.dart';

class ApiService {
  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.login),
        headers: ApiConstants.headers(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': deviceName ?? 'BuyTech Flutter App',
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        await StorageService.saveToken(token);
        await StorageService.saveUser(user);
        return {'success': true, 'user': user, 'token': token};
      }
      return {'success': false, 'message': data['message'] ?? 'فشل تسجيل الدخول'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالخادم، يرجى التأكد من اتصال الإنترنت'};
    }
  }

  // Fetch Smart Cards & Metrics
  static Future<Map<String, dynamic>> getSmartCards() async {
    final token = await StorageService.getToken();
    try {
      final res = await http.get(
        Uri.parse(ApiConstants.smartCards),
        headers: ApiConstants.headers(token: token),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final list = (data['cards'] as List)
            .map((item) => SmartCardModel.fromJson(item as Map<String, dynamic>))
            .toList();
        final stats = data['stats'] as Map<String, dynamic>? ?? {};
        return {'success': true, 'cards': list, 'stats': stats};
      }
      return {'success': false, 'message': data['message'] ?? 'تعذر جلب البطاقات'};
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالشبكة'};
    }
  }

  // Toggle Card Active/Inactive
  static Future<bool> toggleCardStatus(int cardId) async {
    final token = await StorageService.getToken();
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.smartCards}/$cardId/toggle-status'),
        headers: ApiConstants.headers(token: token),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // Fetch Captured Leads CRM
  static Future<List<LeadModel>> getLeads() async {
    final token = await StorageService.getToken();
    try {
      final res = await http.get(
        Uri.parse(ApiConstants.leads),
        headers: ApiConstants.headers(token: token),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['leads'] != null) {
        return (data['leads'] as List)
            .map((i) => LeadModel.fromJson(i as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Fetch Products Catalog
  static Future<List<ProductModel>> getProducts({String? search, String? category}) async {
    final token = await StorageService.getToken();
    try {
      var uri = Uri.parse(ApiConstants.products);
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final res = await http.get(
        uri,
        headers: ApiConstants.headers(token: token),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['products']?['data'] != null) {
        return (data['products']['data'] as List)
            .map((i) => ProductModel.fromJson(i as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Submit Quote to Server
  static Future<bool> submitQuote({
    required List<Map<String, dynamic>> items,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) async {
    final token = await StorageService.getToken();
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.quotes),
        headers: ApiConstants.headers(token: token),
        body: jsonEncode({
          'items': items,
          'customer_name': customerName,
          'customer_phone': customerPhone,
          'notes': notes,
        }),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    final token = await StorageService.getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse(ApiConstants.logout),
          headers: ApiConstants.headers(token: token),
        );
      } catch (_) {}
    }
    await StorageService.clearAuth();
  }
}
