import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/smart_card_model.dart';
import '../models/lead_model.dart';
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
          'device_name': deviceName ?? 'Access Mobile App',
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

  // Create Smart Card
  static Future<Map<String, dynamic>> createSmartCard(Map<String, dynamic> cardData) async {
    final token = await StorageService.getToken();
    try {
      final res = await http.post(
        Uri.parse(ApiConstants.smartCards),
        headers: ApiConstants.headers(token: token),
        body: jsonEncode(cardData),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if ((res.statusCode == 200 || res.statusCode == 201) && data['success'] == true) {
        return {
          'success': true,
          'card': SmartCardModel.fromJson(data['card'] as Map<String, dynamic>),
          'message': data['message'] ?? 'تم إنشاء البطاقة بنجاح',
        };
      }
      return {'success': false, 'message': data['message'] ?? 'فشل إنشاء البطاقة'};
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Update Smart Card
  static Future<Map<String, dynamic>> updateSmartCard(int cardId, Map<String, dynamic> cardData) async {
    final token = await StorageService.getToken();
    try {
      final res = await http.put(
        Uri.parse('${ApiConstants.smartCards}/$cardId'),
        headers: ApiConstants.headers(token: token),
        body: jsonEncode(cardData),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'card': SmartCardModel.fromJson(data['card'] as Map<String, dynamic>),
          'message': data['message'] ?? 'تم تحديث بيانات البطاقة بنجاح',
        };
      }
      return {'success': false, 'message': data['message'] ?? 'فشل تحديث البطاقة'};
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Delete Smart Card
  static Future<bool> deleteSmartCard(int cardId) async {
    final token = await StorageService.getToken();
    try {
      final res = await http.delete(
        Uri.parse('${ApiConstants.smartCards}/$cardId'),
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
