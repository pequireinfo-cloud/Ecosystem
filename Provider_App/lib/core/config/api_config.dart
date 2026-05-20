class ApiConfig {
  // Production Backend URL
  static const String baseUrl = 'https://api.pequire.com/api';
  
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
