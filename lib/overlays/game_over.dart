import 'package:flutter/material.dart';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../core/localization.dart'; // <-- ARTIK AKTİF!
import '../data/data_manager.dart';

class GameOverOverlay extends StatefulWidget {
  final TimelessGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late int earnedCrystals;
  late int score;

  bool _isClaimed = false;

  @override
  void initState() {
    super.initState();
    earnedCrystals = widget.game.buOyunKazanilanKristal;
    score = widget.game.skor;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _watchAdDoubleRewards() {
    widget.game.adManager.showRewardedAd(
      onReward: (amount) {
        setState(() {
          DataManager.totalCoins += earnedCrystals;
          DataManager.saveData();
          widget.game.elmasYazisi.text = '💎 ${DataManager.totalCoins}';
          _isClaimed = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(Dil.get('tebrikler_iki_kat')), // "TEBRİKLER..."
          backgroundColor: Colors.green,
        ));

        widget.game.oyunuBaslat();
      },
      onAdFailed: () {
        debugPrint("Reklam yüklenemedi");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasLoot = earnedCrystals > 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. BLUR ARKA PLAN
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: const Color(0xFF0F172A).withOpacity(0.9)),
          ),

          // 2. MERKEZ KART
          Center(
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: Colors.redAccent.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 5)
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- BAŞLIK ---
                  Text(
                    Dil.get("oyun_bitti"), // "OYUN BİTTİ"
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        shadows: [Shadow(color: Colors.red, blurRadius: 20)]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    Dil.get("bitmedi_mesaj"), // "Ama her şey bitmiş değil..."
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),

                  const SizedBox(height: 30),

                  // --- İSTATİSTİKLER ---
                  Row(
                    children: [
                      // SKOR KUTUSU
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(Dil.get("skor"),
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Text("$score",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // KRİSTAL KUTUSU
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.cyanAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.cyanAccent.withOpacity(0.3))),
                          child: Column(
                            children: [
                              Text(Dil.get("ganimet"),
                                  style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.bold)), // "GANİMET"
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.diamond,
                                      color: Colors.cyanAccent, size: 18),
                                  const SizedBox(width: 5),
                                  Text("$earnedCrystals",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- ANA AKSİYON ---
                  if (hasLoot) ...[
                    if (!_isClaimed)
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: GestureDetector(
                          onTap: _watchAdDoubleRewards,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFF8B5CF6),
                                  Color(0xFFEC4899)
                                ]),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.purpleAccent.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 5))
                                ]),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                      color: Colors.white24,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.play_arrow_rounded,
                                      color: Colors.white, size: 32),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(Dil.get("iki_kat_al"),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18)), // "2 KATINI AL"
                                      Text(Dil.get("iki_kat_aciklama"),
                                          style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontSize:
                                                  11)), // "Ganimeti ikiye katla!"
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.diamond,
                                          color: Colors.yellowAccent, size: 14),
                                      Text("+${earnedCrystals * 2}",
                                          style: const TextStyle(
                                              color: Colors.yellowAccent,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.greenAccent)),
                        child: Center(
                            child: Text(
                                "${Dil.get("odul_alindi")} 💎", // "ÖDÜL ALINDI!"
                                style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold))),
                      ),
                    const SizedBox(height: 20),
                  ],

                  // --- ALT BUTONLAR ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tekrar Oyna
                      _buildSmallButton(
                        icon: Icons.refresh_rounded,
                        label: Dil.get("tekrar_kisa"), // "TEKRAR"
                        color: Colors.white,
                        onTap: () => widget.game.oyunuBaslat(),
                      ),
                      // Ana Menü
                      _buildSmallButton(
                        icon: Icons.home_rounded,
                        label: Dil.get("menu_kisa"), // "MENÜ"
                        color: Colors.white54,
                        onTap: () => widget.game.anaMenuyeDon(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3))),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
