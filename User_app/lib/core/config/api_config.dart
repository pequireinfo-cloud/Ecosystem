class ApiConfig {
  // Using local IP (Connected via Mobile Hotspot)
  static const String baseUrl = 'http://10.46.122.48:4000/api';
  
  // Descope Project ID
  static const String descopeProjectId = 'P3CyZF9IZxcIXXxhQ3fZLgWJmuy5';
  
  // Connection timeout
  static const int connectTimeout = 10000; // 10 seconds
  
  // Shared Headers
  static Map<String, String> get headers => {
    'ngrok-skip-browser-warning': 'true',
    'Bypass-Tunnel-Reminder': 'true',
    'Content-Type': 'application/json',
  };
}
