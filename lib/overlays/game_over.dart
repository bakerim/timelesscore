import 'dart:ui';
import 'package:flutter/material.dart';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';
import '../core/localization.dart';

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

  void _watchScoreAd() {
    widget.game.adManager.showRewardedAd(
      onReward: (amount) {
        setState(() {
          widget.game.skor *= 2;
          DataManager.saveScore(widget.game.skor);
          isScoreAdWatched = true;
        });
        _showToast("Skor 2'ye Katlandı! 🚀", Colors.green);
      },
      onAdFailed: () => _showError(),
    );
  }

  void _watchCrystalAd() {
    widget.game.adManager.showRewardedAd(
      onReward: (amount) {
        setState(() {
          int bonus = widget.game.buOyunKazanilanKristal > 0
              ? widget.game.buOyunKazanilanKristal
              : 2;
          DataManager.totalCoins += bonus;
          DataManager.saveData();
          isCrystalAdWatched = true;
        });
        _showToast("Kristalleriniz Katlandı! 💎", Colors.cyan);
      },
      onAdFailed: () => _showError(),
    );
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showError() {
    _showToast("Reklam yüklenemedi, bağlantını kontrol et.", Colors.redAccent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.black.withValues(alpha: 0.85))),
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
                    const Icon(Icons.videogame_asset_off_rounded,
                        color: Colors.redAccent, size: 60),
                    const SizedBox(height: 10),
                    Text(Dil.get('oyun_bitti').toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                    const SizedBox(height: 25),

                    // --- SKOR BÖLÜMÜ ---
                    _resultBox(
                      label: Dil.get('skor').toUpperCase(),
                      value: "${widget.game.skor}",
                      color: Colors.cyanAccent,
                      isWatched: isScoreAdWatched,
                      onWatch: _watchScoreAd,
                      btnText: "SKORU x2 YAP",
                    ),

                    const SizedBox(height: 15),

                    // --- KRİSTAL BÖLÜMÜ ---
                    _resultBox(
                      label: "KRİSTAL",
                      value: "${widget.game.buOyunKazanilanKristal}",
                      color: Colors.purpleAccent,
                      isWatched: isCrystalAdWatched,
                      onWatch: _watchCrystalAd,
                      btnText: "KRİSTAL x2 YAP",
                      icon: Icons.diamond_rounded,
                    ),

                    const SizedBox(height: 30),

                    // --- BUTONLAR ---
                    _actionButton(
                      label: Dil.get('tekrar_oyna').toUpperCase(),
                      color: Colors.cyanAccent.shade700,
                      onPressed: () => widget.game.oyunuBaslat(),
                      icon: Icons.refresh_rounded,
                    ),
                    const SizedBox(height: 12),

                    // DEĞİŞİKLİK: Doğrudan yeni oluşturduğumuz yolHaritasinaDon'u çağırıyoruz.
                    _actionButton(
                      label: "YOL HARİTASI",
                      color: Colors.white.withValues(alpha: 0.1),
                      onPressed: () => widget.game.yolHaritasinaDon(),
                      isTextBtn: true,
                      icon: Icons.map_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultBox({
    required String label,
    required String value,
    required Color color,
    required bool isWatched,
    required VoidCallback onWatch,
    required String btnText,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color, fontSize: 35, fontWeight: FontWeight.w900)),
              if (icon != null) ...[
                const SizedBox(width: 5),
                Icon(icon, color: color, size: 28),
              ]
            ],
          ),
          const SizedBox(height: 8),
          isWatched
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 5),
                    Text("KATLANDI",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: color.withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: onWatch,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(btnText,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    IconData? icon,
    bool isTextBtn = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: isTextBtn
          ? TextButton.icon(
              style: TextButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              onPressed: onPressed,
              icon: icon != null ? Icon(icon, size: 20) : const SizedBox(),
              label: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            )
          : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              onPressed: onPressed,
              icon: icon != null ? Icon(icon) : const SizedBox(),
              label: Text(label,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2)),
            ),
    );
  }
}
