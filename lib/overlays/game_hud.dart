import 'dart:async';
import 'package:flutter/material.dart';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';
import '../data/progress_manager.dart';
import '../core/localization.dart';

class GameHUD extends StatefulWidget {
  final TimelessGame game;
  const GameHUD({super.key, required this.game});

  @override
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> with TickerProviderStateMixin {
  late AnimationController _readyController;
  late Animation<double> _glowAnimation;

  late Timer _timer;
  int _currentScore = 0;
  int _bestScore = 0;

  @override
  void initState() {
    super.initState();

    // Zaman Bükücü animasyonu
    _readyController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 5.0, end: 15.0).animate(
        CurvedAnimation(parent: _readyController, curve: Curves.easeInOut));

    // SENİN DEĞİŞKENİNLE GÜNCELLENDİ (highScore)
    _bestScore = DataManager.highScore;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          // SENİN DEĞİŞKENİNLE GÜNCELLENDİ (skor)
          _currentScore = widget.game.skor;

          // Oynarken rekor kırılırsa ekrandaki BEST anında güncellenir
          if (_currentScore > _bestScore) {
            _bestScore = _currentScore;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _readyController.dispose();
    super.dispose();
  }

  void _watchAdAndEarn() {
    widget.game.adManager.showRewardedAd(
      onReward: (amount) {
        setState(() {
          DataManager.totalCoins += 3;
          DataManager.saveData();
          // elmasYazisi.text satırını sildik çünkü yeni sistemde skorlar buradan yönetiliyor.
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
        // 1. SOL ÜST: KENDİ TASARIMIN (LEVEL VE KRİSTAL PANELİ)
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
                        _SmallButton(
                          icon: Icons.add,
                          color: Colors.green.shade600,
                          onTap: () => widget.game.overlays.add('ShopMenu'),
                        ),
                        const SizedBox(width: 8),
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

        // 2. SAĞ ÜST: YENİ SKOR VE PAUSE PANELİ (FittedBox ile asla taşmaz)
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreBox(
                      Dil.get('puan'), _currentScore, Colors.cyanAccent),
                  const SizedBox(width: 5),
                  _buildScoreBox(
                      Dil.get('rekor'), _bestScore, Colors.amberAccent),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      widget.game
                          .togglePause(); // pauseEngine() yerine togglePause() kullanıyoruz
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24)),
                      child: const Icon(Icons.pause_rounded,
                          color: Colors.white, size: 24),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),

        // 3. SAĞ ALT: ZAMAN BÜKÜCÜ
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

  // TAŞMAYI ÖNLEYEN KUTU (FittedBox)
  Widget _buildScoreBox(String title, int score, Color highlightColor) {
    return Container(
      width: 65,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlightColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 18,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "$score",
                style: TextStyle(
                  color: highlightColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
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
