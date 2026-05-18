class ApiConfig {
  // Using local IP (Connected via Mobile Hotspot)
  static const String baseUrl = 'http://10.209.29.48:4000/api';
  
  // Descope Project ID
  static const String descopeProjectId = 'P3CyZF9IZxcIXXxhQ3fZLgWJmuy5';

  // State management (Session)
  static String? currentProviderId;
  
  // Shared Headers
  static Map<String, String> get headers => {
    'ngrok-skip-browser-warning': 'true',
    'Bypass-Tunnel-Reminder': 'true',
    'Content-Type': 'application/json',
  };
}
