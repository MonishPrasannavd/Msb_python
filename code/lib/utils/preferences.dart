import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

const String _storageKey = "";
Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
Preferences preferences = Preferences();

class Preferences {
  Future<String> _getApplicationSavedInformation(String name) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_storageKey + name) ?? '';
  }

  Future<bool> _setApplicationSavedInformation(
      String name, String value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString(_storageKey + name, value);
  }

  getPreferredLanguage() async {
    return getPreference('language', "en");
  }

  setPreferredLanguage(String lang) async {
    return _setApplicationSavedInformation('language', lang);
  }

  // ------------------ SINGLETON -----------------------
  static final Preferences _preferences = Preferences._internal();
  factory Preferences() {
    return _preferences;
  }
  Preferences._internal();

  Future<bool?> setPreference(String name, dynamic value) async {
    final SharedPreferences prefs = await _prefs;
    if (value is String) {
      return prefs.setString(_storageKey + name, value);
    } else if (value is int) {
      return prefs.setInt(_storageKey + name, value);
    } else if (value is bool) {
      return prefs.setBool(_storageKey + name, value);
    } else if (value is List<String>) {
      return prefs.setStringList(_storageKey + name, value);
    }
    return null;
  }

  Future<dynamic> getPreference(String name, dynamic defaultValues) async {
    final SharedPreferences prefs = await _prefs;
    if (defaultValues is String) {
      return prefs.getString(_storageKey + name) ?? defaultValues;
    } else if (defaultValues is int) {
      return prefs.getInt(_storageKey + name) ?? defaultValues;
    } else if (defaultValues is bool) {
      return prefs.getBool(_storageKey + name) ?? defaultValues;
    } else if (defaultValues is List<String>) {
      return prefs.getStringList(_storageKey + name) ?? defaultValues;
    }
  }

  Future<bool> containsKeyInPref(String name) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.containsKey(_storageKey + name);
  }

  Future<bool> removeKeyFromPreference(String name) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.remove(_storageKey + name);
  }
}
