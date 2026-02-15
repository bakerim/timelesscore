import 'package:flutter/material.dart';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';
import '../data/progress_manager.dart';

class GameHUD extends StatefulWidget {
  final TimelessGame game;
  const GameHUD({super.key, required this.game});

  @override
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> with TickerProviderStateMixin {
  // Sadece aktif olarak kullandığımız animasyonları bıraktık
  late AnimationController _readyController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Zaman Bükücü butonunun parlamasını yöneten animasyon
    _readyController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 5.0, end: 15.0).animate(
        CurvedAnimation(parent: _readyController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    // Çift tanım hatası giderildi: Sadece bir adet dispose metodu var
    // Olmayan _pulseController satırı silindi, hata temizlendi.
    _readyController.dispose();
    super.dispose();
  }

  // Reklam izleyip kristal kazanma fonksiyonu
  void _watchAdAndEarn() {
    widget.game.adManager.showRewardedAd(
      onReward: (amount) {
        setState(() {
          DataManager.totalCoins += 3;
          DataManager.saveData();
          widget.game.elmasYazisi.text = '💎 ${DataManager.totalCoins}';
        });
      },
      onAdFailed: () => debugPrint("Reklam hatası"),
    );
  }

  @override
  Widget build(BuildContext context) {
    int coins = DataManager.totalCoins;
    const int abilityCost = 5;
    double fillPercent = (coins / abilityCost).clamp(0.0, 1.0);
    bool isReady = coins >= abilityCost;

    return Stack(
      children: [
        // 1. SOL ÜST: LEVEL VE KRİSTAL BİRLEŞİK PANEL
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: Colors.cyanAccent.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LEVEL GÖSTERGESİ (Senkronize)
                    ValueListenableBuilder<double>(
                      valueListenable: ProgressManager().currentXp,
                      builder: (context, xp, child) {
                        int level = ProgressManager().currentLevel.value;
                        double progress = ProgressManager().progressPercentage;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.military_tech,
                                    color: Colors.amberAccent, size: 14),
                                Text(" LEVEL $level",
                                    style: const TextStyle(
                                        color: Colors.cyanAccent,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 80,
                              height: 3,
                              child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation(
                                      Colors.cyanAccent)),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    // KRİSTAL SAYISI VE AKSİYON BUTONLARI
                    Row(
                      children: [
                        const Icon(Icons.diamond,
                            color: Colors.cyanAccent, size: 16),
                        const SizedBox(width: 4),
                        Text("$coins",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(width: 12),
                        // MARKET BUTONU (+) -> Market Sayfasına Yönlendirir
                        _SmallButton(
                          icon: Icons.add,
                          color: Colors.green.shade600,
                          onTap: () => widget.game.overlays.add('ShopMenu'),
                        ),
                        const SizedBox(width: 8),
                        // KRİSTAL KAZAN BUTONU (AD) -> Reklam İzletir
                        _SmallButton(
                          icon: Icons.play_arrow_rounded,
                          color: Colors.orange.shade800,
                          onTap: _watchAdAndEarn,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. SAĞ ALT: ZAMAN BÜKÜCÜ
        Positioned(
          bottom: 160,
          right: 20,
          child: GestureDetector(
            onTap: () {
              if (isReady) {
                widget.game.manuelZamanYavaslat();
                setState(() {});
              } else {
                _watchAdAndEarn();
              }
            },
            child: AnimatedBuilder(
              animation: _readyController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isReady)
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.cyanAccent.withValues(alpha: 0.4),
                                blurRadius: _glowAnimation.value,
                                spreadRadius: 2)
                          ],
                        ),
                      ),
                    SizedBox(
                      width: 62,
                      height: 62,
                      child: CircularProgressIndicator(
                        value: fillPercent,
                        strokeWidth: 3,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation(
                            isReady ? Colors.cyanAccent : Colors.orangeAccent),
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isReady
                              ? [Colors.cyan, Colors.blue]
                              : [Colors.grey.shade800, Colors.black],
                        ),
                      ),
                      child: Icon(
                        isReady ? Icons.ac_unit_rounded : Icons.lock_clock,
                        color: isReady ? Colors.white : Colors.white24,
                        size: 24,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }
}
