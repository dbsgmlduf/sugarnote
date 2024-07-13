import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static Future<int?> getUserNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_no');
  }

  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  static Future<int?> getUserAge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_age');
  }

  static Future<void> clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
