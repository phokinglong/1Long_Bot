import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController {
  static Future<void> saveUserData({
    required String name,
    required String experienceLevel,
    required String goal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('experienceLevel', experienceLevel);
    await prefs.setString('goal', goal);
  }

  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name') ?? '',
      'experienceLevel': prefs.getString('experienceLevel') ?? '',
      'goal': prefs.getString('goal') ?? '',
    };
  }
}
