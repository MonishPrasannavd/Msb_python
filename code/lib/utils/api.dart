class ApiConfig {
  // static const String baseUrl = "localhost:8080";
  static const String baseUrl = "35.163.101.210:8080";
// Private static variable to hold headers
  static final Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    'Accept': '*/*',
    'Cookie': '',
  };

  // Getter for headers
  static Map<String, String> get headers => _headers;

  // Method to update the Cookie header
  static void updateCookie(String cookie) {
    _headers['Cookie'] = cookie;
  }
}
