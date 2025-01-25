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
  static const String BASE_URL = 'https://msb.instabee.pro/pre';
  static const String AUTHENTICATION = '/login';
  static const String GET_PATIENT_BY_ID = '/PatientData/GetPatientByID';
  static const String PATIENT_ID = 'patientID';
  static const String SUBMIT_SPOT_CHECK = '/SpotCheck/SubmitSpotCheck';
  static const String GET_DEVICE_INFO = '/DeviceData/GetSpotCheckDeviceInfo';
  static const String GET_SPOTCHECK_DEVICE_DATA =
      '/DeviceData/GetSpotCheckDeviceData';
}
