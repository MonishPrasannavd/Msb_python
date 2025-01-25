String? fetchFirstName(String? name) {
  if (name != null) {
    return name.trim().split(' ').first;
  } else {
    return null;
  }
}

String? extractUserNameOrFirstName(String? input) {
  // Helper function to check if a string is an email
  bool isEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  if (input == null || input.trim().isEmpty) {
    return null;
  }

  input = input.trim();

  if (isEmail(input)) {
    return input.split('@').first; // Extract part before '@' if it's an email
  } else {
    return fetchFirstName(input); // Call fetchFirstName for non-email strings
  }
}