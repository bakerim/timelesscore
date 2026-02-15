import 'dart:ui';
import 'package:flutter/material.dart';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';

class GameOver extends StatefulWidget {
  final TimelessGame game;
  const GameOver({super.key, required this.game});

  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver>
    with SingleTickerProviderStateMixin {
  bool isScoreAdWatched = false;
  bool isCrystalAdWatched = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Ekrana pat diye gelmesin, yumuşak bir bounce (yaylanma) efektiyle gelsin
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- 1. ÖDÜL: SKORU 2'YE KATLA ---
  void _watchScoreAd() {
    widget.game.adManager.showRewardedAd(
      onReward: (amount) {
        setState(() {
          widget.game.skor *= 2;
          DataManager.saveScore(
              widget.game.skor); // Yeni skoru rekor kontrolü için kaydet
          isScoreAdWatched = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Skor 2'ye Katlandı! 🚀",
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      },
      onAdFailed: () => _showError(),
    );
  }

  // --- 2. ÖDÜL: EKSTRA KRİSTAL ---
  void _watchCrystalAd() {
    widget.game.adManager.showRewardedAd(
      onReward: (amount) {
        setState(() {
          // Eğer oyunda hiç kristal kazanamadıysa teselli olarak 2 tane ver, kazandıysa kazandığı kadar ekstra ver (x2 mantığı)
          int bonus = widget.game.buOyunKazanilanKristal > 0
              ? widget.game.buOyunKazanilanKristal
              : 2;

          DataManager.totalCoins += bonus;
          DataManager.saveData();
          isCrystalAdWatched = true;

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("+$bonus Zaman Kristali Reklam Bonusu! 💎",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.cyan.shade800,
            behavior: SnackBarBehavior.floating,
          ));
        });
      },
      onAdFailed: () => _showError(),
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Reklam yüklenemedi, lütfen bağlantını kontrol et."),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Arka Plan Blur Efekti
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.black.withValues(alpha: 0.85))),

          // Ana İçerik Kutusu
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.4),
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 5)
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- BAŞLIK ---
                    const Icon(Icons.videogame_asset_off_rounded,
                        color: Colors.redAccent, size: 60),
                    const SizedBox(height: 10),
                    const Text("OYUN BİTTİ",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                    const SizedBox(height: 25),

                    // --- SKOR BÖLÜMÜ ---
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          Text("SKOR",
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2)),
                          Text("${widget.game.skor}",
                              style: const TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 45,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 10),
                          isScoreAdWatched
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.green, size: 18),
                                      SizedBox(width: 5),
                                      Text("2'YE KATLANDI",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold))
                                    ])
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange.shade700,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      elevation: 5,
                                    ),
                                    onPressed: _watchScoreAd,
                                    icon: const Icon(
                                        Icons.ondemand_video_rounded,
                                        size: 20),
                                    label: const Text("SKORU 2'YE KATLA",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // --- KRİSTAL BÖLÜMÜ ---
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          Text("KAZANILAN KRİSTAL",
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2)),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${widget.game.buOyunKazanilanKristal}",
                                  style: const TextStyle(
                                      color: Colors.purpleAccent,
                                      fontSize: 35,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(width: 5),
                              const Icon(Icons.diamond_rounded,
                                  color: Colors.purpleAccent, size: 30),
                            ],
                          ),
                          const SizedBox(height: 10),
                          isCrystalAdWatched
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.green, size: 18),
                                      SizedBox(width: 5),
                                      Text("BONUS ALINDI",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold))
                                    ])
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      elevation: 5,
                                    ),
                                    onPressed: _watchCrystalAd,
                                    icon: const Icon(
                                        Icons.play_circle_fill_rounded,
                                        size: 20),
                                    label: const Text("EKSTRA KRİSTAL AL",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // --- ANA MENÜYE DÖN ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        onPressed: () {
                          // Kusursuz Navigasyon: TimelessGame içindeki metod çağrılır
                          widget.game.anaMenuyeDon();
                        },
                        child: const Text("ANA MENÜYE DÖN",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
