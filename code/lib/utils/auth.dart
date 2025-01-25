import 'package:flutter/material.dart';
import 'package:msb_app/Screens/sign_in/sign_in_screen.dart';
import 'package:msb_app/services/preferences_service.dart';

class AuthUtils {
  static VoidCallback handleLogout(BuildContext context) {
    return () async {
      // Clear preferences and navigate to login screen
      await PrefsService.clear();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
            (route) => false,
      );
    };
  }
}

