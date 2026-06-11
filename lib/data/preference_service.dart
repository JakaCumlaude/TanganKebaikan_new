import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String keyLoggedIn = "is_logged_in";
  static const String keyName = "user_name";
  static const String keyEmail = "user_email";
  static const String keyPhone = "user_phone";
  static const String keyDarkMode = "is_dark_mode";
  static const String keyDonationCount = "total_donation_count";

  // Save All Profile Data
  Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
    required bool darkMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLoggedIn, true);
    await prefs.setString(keyName, name);
    await prefs.setString(keyEmail, email);
    await prefs.setString(keyPhone, phone);
    await prefs.setBool(keyDarkMode, darkMode);
  }

  // Getters
  Future<Map<String, dynamic>> getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      keyLoggedIn: prefs.getBool(keyLoggedIn) ?? false,
      keyName: prefs.getString(keyName) ?? "Kebaikan User",
      keyEmail: prefs.getString(keyEmail) ?? "user@tangankebaikan.org",
      keyPhone: prefs.getString(keyPhone) ?? "081234567890",
      keyDarkMode: prefs.getBool(keyDarkMode) ?? false,
      keyDonationCount: prefs.getInt(keyDonationCount) ?? 0,
    };
  }

  Future<void> incrementDonationCount() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(keyDonationCount) ?? 0;
    await prefs.setInt(keyDonationCount, current + 1);
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyLoggedIn, false);
  }
}
