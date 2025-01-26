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

class AppUrl {
  static const String BASE_URL = 'https://msb.instabee.pro';
  static const String AUTHENTICATION = '/pre/login';
  static const String SIGNUP = '/pre/register';
  static const String GET_PATIENT_BY_ID = '/PatientData/GetPatientByID';
  static const String PATIENT_ID = 'patientID';
  static const String SUBMIT_SPOT_CHECK = '/SpotCheck/SubmitSpotCheck';
  static const String GET_DEVICE_INFO = '/DeviceData/GetSpotCheckDeviceInfo';
  static const String GET_SPOTCHECK_DEVICE_DATA = '/DeviceData/GetSpotCheckDeviceData';
  static const String GET_MASTERDATA = '/masters/all';
  static const String GET_USERME = '/auth/me';
  static const String GET_USER = '/users/get-user';
  static const String LOGOUT = '/auth/logout';
  static const String UPDATE_USER = '/auth/me/update-profile';

  /// Private headers map
  static final Map<String, String> _headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Getter for headers
  static Map<String, String> get headers => Map.unmodifiable(_headers);

  /// Add or update a header
  static void addHeader(String key, String value) {
    _headers[key] = value;
  }

  /// Remove a header
  static void removeHeader(String key) {
    _headers.remove(key);
  }

  /// Clear all headers
  static void clearHeaders() {
    _headers.clear();
  }
}
