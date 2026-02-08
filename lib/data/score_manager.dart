import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static int highScore = 0;

  static Future<void> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('high_score') ?? 0;
  }

  static Future<void> kaydet(int score) async {
    if (score > highScore) {
      highScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('high_score', highScore);
    }
  }
}
