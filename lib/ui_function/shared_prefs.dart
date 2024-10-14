import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  // static SharedPreferences? _preference;

  // static Future setPrefsInstance(String token) async {
  //   _preference ??= await SharedPreferences.getInstance();
  //   return _preference;
  // }

  static Future<void> setAccessToken(
    String accessToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
  }

  static Future<void> setRefreshToken(
      String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', refreshToken);
  }

  static Future<String?> fetchAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<String?> fetchRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  static Future<void> clearAuthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token'); // access_tokenを削除
    await prefs.remove('refresh_token'); // refresh_tokenを削除
  }

  static Future<void> setStaffAccessToken(
    String accessToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('staff_access_token', accessToken);
  }

  static Future<void> setStaffRefreshToken(
      String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('staff_refresh_token', refreshToken);
  }

  static Future<String?> fetchStaffAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('staff_access_token');
  }

  static Future<String?> fetchStaffRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('staff_refresh_token');
  }

  static Future<void> clearStaffAuthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('staff_access_token'); // access_tokenを削除
    await prefs.remove('staff_refresh_token'); // refresh_tokenを削除
  }
}
