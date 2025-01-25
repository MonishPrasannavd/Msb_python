extension ExtString on String {
  bool get isValidName{
    final nameRegExp = RegExp(r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$");
    return nameRegExp.hasMatch(this);
  }

  bool get isValidPassword{
    final passwordRegExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\><*~]).{8,}/pre>');
    return passwordRegExp.hasMatch(this);
  }

  bool get isValidEmail {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }

  bool get isNotNull{
    // ignore: unnecessary_null_comparison
    return this!=null;
  }

  bool get isValidPhone{
    final phoneRegExp = RegExp(r"^\+?[0-9]{15}$");
    return phoneRegExp.hasMatch(this);
  }


  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String get formatAmount {
    return double.parse(this).toStringAsFixed(2);
  }
}

extension DoubleHelper on double{
  String formatAmount() {
    return toStringAsFixed(2);
  }
}

extension StringHelper on String?{
  String formatAmount() {
    return double.parse(this ?? '0').toStringAsFixed(2);
  }

  double formatDouble() {
    return double.parse(this ?? '0');
  }
}

extension StringExtension on String {
  String capitalizeText() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}