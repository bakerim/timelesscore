import 'package:flutter/material.dart';
import '../data/progress_manager.dart';
import '../game/timeless_game.dart';
import '../core/localization.dart';
import '../core/constants.dart' as Core;

class RoadmapOverlay extends StatelessWidget {
  final TimelessGame game;
  const RoadmapOverlay({super.key, required this.game});

  // Romen Rakamları Listesi
  static const List<String> _romenRakamlari = ["", "I", "II", "III", "IV", "V"];

  @override
  Widget build(BuildContext context) {
    final pm = ProgressManager();
    final currentLevel = pm.level;
    final currentXp = pm.xp;
    final nextLevelXp = pm.nextLevelXp(currentLevel);
    final progress = (currentXp / nextLevelXp).clamp(0.0, 1.0);

    // Mevcut rütbe anahtarını bul
    String rutbeAnahtari = _rutbeAnahtariBul(pm.rankName);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.black.withOpacity(0.9),
        child: Center(
          child: Container(
            width: 350,
            height: 600,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Core.Tasarim.arkaPlan, // Artık hata vermeyecek
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.5), width: 2),
            ),
            child: Column(
              children: [
                Text(Dil.get("yol_haritasi"),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                const Divider(color: Colors.white24, height: 30),

                // GÜNCEL DURUM KARTI
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: Colors.blueAccent, shape: BoxShape.circle),
                        child: Text("$currentLevel",
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // DİNAMİK ROMEN RAKAMI (I'den V'e kadar döner)
                            Text(
                                "${Dil.get(rutbeAnahtari)} ${_romenSayi(currentLevel % 5 == 0 ? 5 : currentLevel % 5)}",
                                style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: Colors.black,
                                  color: Colors.greenAccent),
                            ),
                            const SizedBox(height: 5),
                            Text("$currentXp / $nextLevelXp XP",
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // LEVEL LİSTESİ
                Expanded(
                  child: ListView.builder(
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      int lvl = index + 1;
                      bool isUnlocked = lvl <= currentLevel;
                      bool isCurrent = lvl == currentLevel;
                      String listeRutbe = _rutbeAnahtariSimule(lvl);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: isCurrent
                                ? Colors.blue.withOpacity(0.2)
                                : (isUnlocked
                                    ? Colors.white10
                                    : Colors.transparent),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Icon(isUnlocked ? Icons.check_circle : Icons.lock,
                                color: isUnlocked ? Colors.green : Colors.grey,
                                size: 20),
                            const SizedBox(width: 15),
                            Text("Level $lvl",
                                style: TextStyle(
                                    color:
                                        isUnlocked ? Colors.white : Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            // LİSTEDEKİ ROMEN RAKAMLARI
                            Text(
                                "${Dil.get(listeRutbe)} ${_romenSayi(lvl % 5 == 0 ? 5 : lvl % 5)}",
                                style: TextStyle(
                                    color: isUnlocked
                                        ? Colors.amberAccent
                                        : Colors.white24,
                                    fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      game.overlays.remove('Roadmap');
                      game.overlays.add('AnaMenu');
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10),
                    child: Text(Dil.get("geri"),
                        style: const TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _romenSayi(int sayi) =>
      (sayi > 0 && sayi <= 5) ? _romenRakamlari[sayi] : "";

  String _rutbeAnahtariBul(String hamIsim) {
    if (hamIsim.contains("Acemi")) return "acemi";
    if (hamIsim.contains("Çırak")) return "cirak";
    if (hamIsim.contains("Uzman")) return "uzman";
    if (hamIsim.contains("Usta")) return "usta";
    if (hamIsim.contains("Efsane")) return "efsane";
    if (hamIsim.contains("Boyut")) return "boyut_gezgini";
    return "acemi";
  }

  String _rutbeAnahtariSimule(int lvl) {
    if (lvl <= 5) return "acemi";
    if (lvl <= 10) return "cirak";
    if (lvl <= 15) return "uzman";
    if (lvl <= 20) return "usta";
    if (lvl <= 25) return "efsane";
    return "boyut_gezgini";
  }
}
