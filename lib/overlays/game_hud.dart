import 'dart:ui';
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
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  late Timer _timer;
  int _currentScore = 0;
  int _bestScore = 0;

  // --- OYUN İÇİ BLOK BARI (KAR TOPU ETKİSİ) ---
  int _lastRewardBlocks = 0;
  int _nextRewardBlocks = 100; // Artık her 100 blokta bir doluyor!
  int _currentBlocks = 0;
  bool _isBarRewardReady = false;

  // --- REKLAM POLİTİKASI GÜVENLİ BİLDİRİM SİSTEMİ ---
  String? _feedbackText;
  Color? _feedbackColor;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _bestScore = DataManager.highScore;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _currentScore = widget.game.skor;
          if (_currentScore > _bestScore) {
            _bestScore = _currentScore;
          }

          // Bar artık blok sayısını dinliyor!
          _currentBlocks = widget.game.blocksPlaced;

          if (_currentBlocks >= _nextRewardBlocks && !_isBarRewardReady) {
            _isBarRewardReady = true;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _feedbackTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _showSkillFeedback(String text, Color color) {
    setState(() {
      _feedbackText = text;
      _feedbackColor = color;
    });
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _feedbackText = null);
    });
  }

  void _watchAdAndEarn() {
    widget.game.togglePause();
    widget.game.adManager.showRewardedAd(
      onReward: (amount) {
        setState(() {
          DataManager.totalCoins += 3;
          DataManager.saveData();
        });
        widget.game.togglePause();
        _showSkillFeedback("+3 KRİSTAL EKLENDİ!", Colors.greenAccent);
      },
      onAdFailed: () {
        widget.game.togglePause();
        _showSkillFeedback("Reklam Yüklenemedi", Colors.orangeAccent);
      },
    );
  }

  void _claimBarReward() {
    widget.game.togglePause();
    widget.game.adManager.showRewardedAd(
      onReward: (amount) {
        setState(() {
          DataManager.totalCoins += 5;
          DataManager.saveData();

          // Ödül alındı, bir sonraki 100 hedefine geç!
          _lastRewardBlocks = _currentBlocks;
          _nextRewardBlocks = _currentBlocks + 100;
          _isBarRewardReady = false;
        });
        widget.game.togglePause();
        _showSkillFeedback("+5 KRİSTAL KAZANDIN!", Colors.purpleAccent);
      },
      onAdFailed: () {
        widget.game.togglePause();
        _showSkillFeedback("Bağlantı Hatası!", Colors.redAccent);
      },
    );
  }

  void _useSlowMo() {
    if (widget.game.isTimeSlowed) return;

    if (DataManager.totalCoins >= 5) {
      widget.game.manuelZamanYavaslat();
      _showSkillFeedback("ZAMAN BÜKÜLDÜ!", Colors.cyanAccent);
    } else {
      widget.game.togglePause();
      widget.game.adManager.showRewardedAd(
        onReward: (_) {
          DataManager.totalCoins += 5;
          widget.game.manuelZamanYavaslat();
          widget.game.togglePause();
          _showSkillFeedback("ZAMAN BÜKÜLDÜ!", Colors.cyanAccent);
        },
        onAdFailed: () {
          widget.game.togglePause();
          _showSkillFeedback("Bağlantı Hatası!", Colors.redAccent);
        },
      );
    }
  }

  void _useMegaBomb() {
    const int bombCost = 15;

    if (DataManager.totalCoins >= bombCost) {
      DataManager.totalCoins -= bombCost;
      DataManager.saveData();
      widget.game.altSatirlariTemizle();
      _showSkillFeedback("MEGA BOMBA!", Colors.redAccent);
    } else {
      widget.game.togglePause();
      widget.game.adManager.showRewardedAd(
        onReward: (_) {
          widget.game.altSatirlariTemizle();
          widget.game.togglePause();
          _showSkillFeedback("MEGA BOMBA!", Colors.redAccent);
        },
        onAdFailed: () {
          widget.game.togglePause();
          _showSkillFeedback("Bağlantı Hatası!", Colors.redAccent);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int coins = DataManager.totalCoins;
    bool canAffordSlowMo = coins >= 5;
    bool canAffordBomb = coins >= 15;

    return Stack(
      children: [
        if (_feedbackText != null)
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _feedbackText != null ? 1.0 : 0.0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _feedbackColor!, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: _feedbackColor!.withValues(alpha: 0.5),
                          blurRadius: 10)
                    ],
                  ),
                  child: Text(
                    _feedbackText!,
                    style: TextStyle(
                        color: _feedbackColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 16),
                  ),
                ),
              ),
            ),
          ),

        // 1. SOL ÜST PANEL
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
                                Text(" ${Dil.get('seviye')} $level",
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
                          onTap: () {
                            widget.game.togglePause();
                            widget.game.overlays.add('ShopMenu');
                          },
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

        // 2. SAĞ ÜST PANEL
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildScoreBox(
                          Dil.get('puan'), _currentScore, Colors.cyanAccent),
                      const SizedBox(width: 5),
                      _buildScoreBox(
                          Dil.get('rekor'), _bestScore, Colors.amberAccent),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => widget.game.togglePause(),
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
                  const SizedBox(height: 8),

                  // --- GÜNCELLENEN BLOK BAZLI BARRR ---
                  _buildGreedBar(),
                ],
              ),
            ),
          ),
        ),

        // 3. SOL YETENEK BAR
        Positioned(
          left: 15,
          bottom: 65,
          child: _buildHorizontalSkillButton(
            icon: Icons.hourglass_bottom_rounded,
            color: Colors.cyanAccent,
            costText: "5 💎",
            isAdBtn: !canAffordSlowMo,
            onTap: _useSlowMo,
            isPulsing: _currentScore > 500 && !widget.game.isTimeSlowed,
          ),
        ),

        // 4. SAĞ YETENEK BAR
        Positioned(
          right: 15,
          bottom: 65,
          child: _buildHorizontalSkillButton(
            icon: Icons.local_fire_department_rounded,
            color: Colors.redAccent,
            costText: "15 💎",
            isAdBtn: !canAffordBomb,
            onTap: _useMegaBomb,
            isPulsing: !canAffordBomb,
          ),
        ),
      ],
    );
  }

  // --- BLOK İLE DOLAN GÖREV BARI ---
  Widget _buildGreedBar() {
    double barProgress = (_currentBlocks - _lastRewardBlocks) /
        (_nextRewardBlocks - _lastRewardBlocks);
    barProgress = barProgress.clamp(0.0, 1.0);

    if (_isBarRewardReady) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: _claimBarReward,
          child: Container(
            width: 135,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.pinkAccent]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.5), blurRadius: 8)
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text("5 💎 AL",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 135,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.view_in_ar_rounded,
                    color: Colors.white54, size: 12),
                Text(
                    "${_currentBlocks - _lastRewardBlocks}/${_nextRewardBlocks - _lastRewardBlocks}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: barProgress,
                minHeight: 4,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation(Colors.purpleAccent),
              ),
            )
          ],
        ),
      );
    }
  }

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
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          SizedBox(
            height: 18,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text("$score",
                  style: TextStyle(
                      color: highlightColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalSkillButton({
    required IconData icon,
    required Color color,
    required String costText,
    required bool isAdBtn,
    required VoidCallback onTap,
    required bool isPulsing,
  }) {
    Widget buttonContent = GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
              boxShadow: isPulsing
                  ? [
                      BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 2)
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                isAdBtn
                    ? Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 14),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(costText,
                            style: const TextStyle(
                                color: Colors.yellowAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );

    return isPulsing
        ? ScaleTransition(scale: _scaleAnimation, child: buttonContent)
        : buttonContent;
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
