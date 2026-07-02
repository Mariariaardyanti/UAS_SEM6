class ApiConstants {
  // Ganti dengan URL backend kamu
  static const String baseUrl = 'http://192.168.1.2:8081/v1';
  
  // Base URL backend Dompet Kampus Global (be-emoney) — untuk setup TOTP
  static const String emoneyBaseUrl = 'http://192.168.1.2:8080/v1';
  static void debug() {
    print("================================");
    print("BASE URL = $baseUrl");
    print("================================");
  }

  // Auth endpoints
  static const String verifyToken = '/auth/verify-token';
  static const String refreshToken = '/auth/refresh';
  static const String fcmToken = '/auth/fcm-token';

  // Product endpoints
  static const String products = '/products';

  // Cart endpoints
  static const String cart = '/cart';

  // Order endpoints
  static const String orders = '/orders';
  static const String checkout = '/orders/checkout';

  static const setupOTP = "/auth/setup-otp";
  static const verifyOTP = "/auth/verify-otp";

  // Timeouts
  static const int connectTimeout = 15000; // ms
  static const int receiveTimeout = 15000;
}
