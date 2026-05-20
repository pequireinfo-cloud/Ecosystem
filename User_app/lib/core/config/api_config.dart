class ApiConfig {
  // Production Backend URL
  static const String baseUrl = 'https://api.pequire.com/api';
  
  // Descope Project ID
  static const String descopeProjectId = 'P3CyZF9IZxcIXXxhQ3fZLgWJmuy5';
  
  // Connection timeout
  static const int connectTimeout = 10000; // 10 seconds
  
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  // Shared Headers
  static Map<String, String> get headers {
    final map = {
      'ngrok-skip-browser-warning': 'true',
      'Bypass-Tunnel-Reminder': 'true',
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      map['Authorization'] = 'Bearer $_token';
    }
    return map;
  }
}
