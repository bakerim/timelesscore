import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import '../game/timeless_game.dart';
import '../core/localization.dart';
import '../data/data_manager.dart';

class RoadmapOverlay extends StatefulWidget {
  final TimelessGame game;
  const RoadmapOverlay({super.key, required this.game});

  @override
  State<RoadmapOverlay> createState() => _RoadmapOverlayState();
}

class _RoadmapOverlayState extends State<RoadmapOverlay>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  // Animasyonlu arka plan için (Bu hafif bir animasyon, donma yapmaz)
  late AnimationController _bgController;

  // Level durumlarını tutmak için
  Set<int> _claimedLevels = {};

  final int _totalLevels = 99;

  @override
  void initState() {
    super.initState();

    // Arka plan hafifçe renk değiştirsin (Nefes alma efekti)
    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat(reverse: true);

    // Otomatik Kaydırma
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        double itemHeight = 120.0;
        double targetPos =
            (_totalLevels - widget.game.currentLevel) * itemHeight;
        double screenHeight = MediaQuery.of(context).size.height;
        targetPos -= screenHeight / 2;

        _scrollController.animateTo(
          targetPos.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _claimReward(int level, int amount) {
    setState(() {
      _claimedLevels.add(level);
      DataManager.totalCoins += amount;
      DataManager.saveData();
    });

    // UI Güncelleme
    widget.game.elmasYazisi.text = '💎 ${DataManager.totalCoins}';
    widget.game.sesCal('sfx/coin.mp3');

    // Basit ve Şık Bildirim
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white),
        const SizedBox(width: 10),
        Text("+$amount Kristal Hesabına Eklendi!",
            style: const TextStyle(fontWeight: FontWeight.bold))
      ]),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(20),
    ));
  }

  void _showPremiumRewardDialog(int level) {
    int baseReward = 5 + (level ~/ 5);
    int adReward = baseReward * 3;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Reward",
      pageBuilder: (ctx, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Colors.cyanAccent.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 5)
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- HEADER ---
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [
                                Colors.amber.withOpacity(0.5),
                                Colors.transparent
                              ])),
                        ),
                        const Icon(Icons.card_giftcard,
                            size: 80, color: Colors.amberAccent),
                      ],
                    ),

                    Text(
                      "SEVİYE $level ÖDÜLÜ",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Ödülünü nasıl almak istersin?",
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 25),

                    // --- SEÇENEK A: REKLAM İZLE (3X) ---
                    GestureDetector(
                      onTap: () {
                        // 1. Önce Diyaloğu Kapat (Çakışmayı önler)
                        Navigator.pop(ctx);

                        // 2. Kullanıcıya bilgi ver (Opsiyonel)
                        debugPrint("Reklam isteniyor...");

                        // 3. Reklamı Başlat
                        widget.game.adManager.showRewardedAd(
                          onReward: (amount) {
                            debugPrint("Reklam izlendi, ödül veriliyor.");
                            _claimReward(level, adReward);
                          },
                          onAdFailed: () {
                            // Reklam yüklenemezse kullanıcıyı mağdur etme, normal ödülü ver
                            debugPrint(
                                "Reklam hatası, teselli ödülü veriliyor.");
                            _claimReward(level, baseReward);

                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  "Reklam yüklenemedi, standart ödül verildi."),
                              backgroundColor: Colors.orange,
                            ));
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Color(0xFF8B5CF6),
                              Color(0xFFEC4899)
                            ]), // Mor-Pembe
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.purpleAccent.withOpacity(0.4),
                                  blurRadius: 15,
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
                                  color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("3 KATI KAZAN",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16)),
                                  Text("Kısa bir reklam izle",
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 10)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                const Icon(Icons.diamond,
                                    color: Colors.yellowAccent, size: 16),
                                Text("+$adReward",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // --- SEÇENEK B: STANDART ---
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _claimReward(level, baseReward);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 15),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text("Hayır, sadece $baseReward al",
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.diamond,
                                color: Colors.grey, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) => child,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. DİNAMİK ARKA PLAN
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  const Color(0xFF0F172A),
                  Color.lerp(const Color(0xFF1E1B4B), const Color(0xFF312E81),
                      _bgController.value)!
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              );
            },
          ),

          // 2. ANA İÇERİK
          Column(
            children: [
              // --- APP BAR ---
              SafeArea(
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          widget.game.overlays.remove('Roadmap');
                          widget.game.overlays.add('AnaMenu');
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.white10),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Dil.get("yol_haritasi").toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2),
                          ),
                          Text(
                            "Level ${widget.game.currentLevel} / $_totalLevels",
                            style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // --- ROADMAP LIST ---
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100, top: 50),
                  itemCount: _totalLevels,
                  itemBuilder: (context, index) {
                    final int level = _totalLevels - index;
                    return _buildPathSegment(level);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPathSegment(int level) {
    final int currentLevel = widget.game.currentLevel;
    bool isLocked = level > currentLevel;
    bool isCurrent = level == currentLevel;
    bool isClaimed = _claimedLevels.contains(level);
    bool isBoss = level % 10 == 0;
    bool isReward = level % 5 == 0;

    double offsetX = sin(level * 0.5) * 80;
    double nextOffsetX = sin((level - 1) * 0.5) * 80;

    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // A) YOL ÇİZGİSİ
          if (level > 1)
            CustomPaint(
              size: const Size(double.infinity, 120),
              painter: PathPainter(
                startX: offsetX,
                endX: nextOffsetX,
                isLocked: isLocked,
              ),
            ),

          // B) LEVEL DÜĞÜMÜ
          Transform.translate(
            offset: Offset(offsetX, 0),
            child: GestureDetector(
              onTap: () {
                if (isLocked) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Daha bu seviyeye gelmedin! 🔒"),
                      duration: Duration(milliseconds: 500),
                      backgroundColor: Colors.redAccent));
                } else if (isClaimed) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Bu ödülü zaten aldın! ✅"),
                      duration: Duration(milliseconds: 500)));
                } else {
                  _showPremiumRewardDialog(level);
                }
              },
              child: _buildNodeContent(
                  level, isLocked, isCurrent, isClaimed, isBoss, isReward),
            ),
          ),

          // C) YAN BİLGİ
          Transform.translate(
            offset: Offset(offsetX + (offsetX > 0 ? -60 : 60), 0),
            child: Text(
              "$level",
              style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.white24,
                  fontSize: isCurrent ? 24 : 14,
                  fontWeight: FontWeight.w900),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNodeContent(int level, bool isLocked, bool isCurrent,
      bool isClaimed, bool isBoss, bool isReward) {
    double size = isBoss ? 80 : 60;
    Color color = isLocked
        ? Colors.grey.shade800
        : (isClaimed
            ? Colors.green.shade900
            : (isBoss ? Colors.redAccent : Colors.cyan));
    IconData icon = isLocked
        ? Icons.lock
        : (isClaimed
            ? Icons.check
            : (isReward ? Icons.card_giftcard : Icons.play_arrow));

    bool isClaimable = !isLocked && !isClaimed;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: isClaimable ? 1.1 : 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                    color: isCurrent ? Colors.white : Colors.white24,
                    width: isCurrent ? 4 : 2),
                boxShadow: isClaimable
                    ? [BoxShadow(color: color, blurRadius: 20, spreadRadius: 2)]
                    : [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5,
                            offset: const Offset(0, 5))
                      ]),
            child: Icon(icon, color: Colors.white, size: size * 0.5),
          ),
        );
      },
      onEnd: () {},
    );
  }
}

// YOL ÇİZİCİ (Kıvrımlı Hatlar)
class PathPainter extends CustomPainter {
  final double startX;
  final double endX;
  final bool isLocked;

  PathPainter(
      {required this.startX, required this.endX, required this.isLocked});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isLocked ? Colors.white10 : Colors.cyanAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double centerX = size.width / 2;
    double startY = size.height / 2;
    double endY = size.height * 1.5;

    path.moveTo(centerX + startX, startY);

    path.cubicTo(centerX + startX, size.height, centerX + endX, size.height,
        centerX + endX, endY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
