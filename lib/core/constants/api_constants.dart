class ApiConstants {
  // Production Cloud Server URL for BuyTech
  static const String baseUrl = 'https://op-system.buytech.app/api';
  
  // Local Development Fallback
  static const String localUrl = 'http://10.0.2.2:8000/api'; // Android Emulator alias to 127.0.0.1

  // Endpoints
  static const String ping = '$baseUrl/ping';
  static const String login = '$baseUrl/login';
  static const String me = '$baseUrl/me';
  static const String logout = '$baseUrl/logout';
  static const String smartCards = '$baseUrl/smart-cards';
  static const String leads = '$baseUrl/leads';
  static const String products = '$baseUrl/products';
  static const String quotes = '$baseUrl/quotes';
  static const String tasks = '$baseUrl/tasks';

  // Request Headers
  static Map<String, String> headers({String? token}) {
    final map = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      map['Authorization'] = 'Bearer $token';
    }
    return map;
  }
}
