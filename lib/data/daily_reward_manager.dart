import 'package:shared_preferences/shared_preferences.dart';

class DailyRewardManager {
  // Singleton yapısı (isteğe bağlı ama temiz olur)
  static final DailyRewardManager _instance = DailyRewardManager._internal();
  factory DailyRewardManager() => _instance;
  DailyRewardManager._internal();

  static const String _keyLastRewardTime = 'last_reward_time';

  // Ödül alınabilir mi? (Son ödül tarihi bugün değilse true döner)
  Future<bool> canClaimReward() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTimeMillis = prefs.getInt(_keyLastRewardTime) ?? 0;

    // Eğer hiç kayıt yoksa (ilk açılış), ödül alınabilir
    if (lastTimeMillis == 0) return true;

    final lastDate = DateTime.fromMillisecondsSinceEpoch(lastTimeMillis);
    final now = DateTime.now();

    // Yıl, Ay ve Gün aynı ise "bugün alınmış" demektir.
    // Değilse "yeni gün" demektir ve ödül alınabilir.
    bool isSameDay = lastDate.year == now.year &&
        lastDate.month == now.month &&
        lastDate.day == now.day;

    return !isSameDay;
  }

  // Ödülü aldı olarak işaretle
  Future<void> markAsClaimed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _keyLastRewardTime, DateTime.now().millisecondsSinceEpoch);
  }
}
