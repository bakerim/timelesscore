
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';
import '../data/progress_manager.dart';

class RoadmapOverlay extends StatefulWidget {
  final TimelessGame game;
  const RoadmapOverlay({super.key, required this.game});

  @override
  State<RoadmapOverlay> createState() => _RoadmapOverlayState();
}

class _RoadmapOverlayState extends State<RoadmapOverlay>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _bgController;

  final int _totalLevels = 100;

  @override
  void initState() {
    super.initState();

    _bgController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat(reverse: true);

    // Otomatik Kaydırma (Güncel Kariyer Seviyesine Odaklan)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        double itemHeight = 120.0;
        int currentLvl = ProgressManager().currentLevel.value;

        // Listenin ters olmasından dolayı hesaplama
        double targetPos = (_totalLevels - currentLvl) * itemHeight;
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

  // --- REWARD CLAIM (ÖDÜL ALMA) SİSTEMİ (GLITCH FİXLENDİ!) ---
  void _claimReward(int level, int amount) {
    setState(() {
      // YENİ: Artık geçici değil, kalıcı DataManager'a kaydediyoruz!
      DataManager.claimReward(level);
      DataManager.totalCoins += amount;
      DataManager.saveData();
    });

    // UI'daki kristal sayısını anında güncelle

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white),
        const SizedBox(width: 10),
        Text("+$amount Kristal Hesabına Eklendi! 💎",
            style: const TextStyle(fontWeight: FontWeight.bold))
      ]),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
    ));
  }

  // --- REKLAMLI / NORMAL ÖDÜL DİYALOĞU ---
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
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Colors.cyanAccent.withValues(alpha: 0.5),
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 5)
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Görsel
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [
                                  Colors.amber.withValues(alpha: 0.5),
                                  Colors.transparent
                                ]))),
                        const Icon(Icons.card_giftcard_rounded,
                            size: 80, color: Colors.amberAccent),
                      ],
                    ),

                    // Metinler
                    Text("SEVİYE $level ÖDÜLÜ",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1)),
                    const SizedBox(height: 5),
                    const Text("Ödülünü nasıl almak istersin?",
                        style: TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 25),

                    // --- REKLAM İZLE BUTONU (3X) ---
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        widget.game.adManager.showRewardedAd(
                          onReward: (amount) => _claimReward(level, adReward),
                          onAdFailed: () {
                            _claimReward(level,
                                baseReward); // Hata olursa standart ödülü ver mağdur etme
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Reklam yüklenemedi, standart ödül verildi."),
                                    backgroundColor: Colors.orange));
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.purpleAccent
                                      .withValues(alpha: 0.4),
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
                                    color: Colors.white, size: 30)),
                            const SizedBox(width: 15),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  const Text("3 KATI KAZAN",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16)),
                                  Text("Kısa bir reklam izle",
                                      style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                          fontSize: 10))
                                ])),
                            Column(children: [
                              const Icon(Icons.diamond_rounded,
                                  color: Colors.yellowAccent, size: 16),
                              Text("+$adReward",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20))
                            ])
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // --- STANDART AL BUTONU (1X) ---
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _claimReward(level, baseReward);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 15),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
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
                                            fontWeight: FontWeight.bold)))),
                            const SizedBox(width: 5),
                            const Icon(Icons.diamond_rounded,
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
              // --- APP BAR VE SENKRONİZE LEVEL BİLGİSİ ---
              SafeArea(
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // KUSURSUZ NAVİGASYON (Siyah ekran düşmanı)
                      IconButton(
                        onPressed: () => widget.game.anaMenuyeDon(),
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
                          const Text("YOL HARİTASI",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2)),
                          // Sinerji: ProgressManager'ı dinler!
                          ValueListenableBuilder<int>(
                              valueListenable: ProgressManager().currentLevel,
                              builder: (context, currentLevel, child) {
                                return Text(
                                  "Mevcut: Level $currentLevel / $_totalLevels",
                                  style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                );
                              }),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // --- KIVRIMLI ROADMAP (SENİN TASARIMIN) ---
              Expanded(
                child: ValueListenableBuilder<int>(
                    valueListenable: ProgressManager().currentLevel,
                    builder: (context, currentLevel, child) {
                      return ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 150, top: 50),
                        itemCount: _totalLevels,
                        itemBuilder: (context, index) {
                          // Level tersine sıralanır (Aşağıdan yukarı gitme hissi için)
                          final int nodeLevel = _totalLevels - index;
                          return _buildPathSegment(nodeLevel, currentLevel);
                        },
                      );
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- KIVRIMLI DÜĞÜM OLUŞTURUCU ---
  Widget _buildPathSegment(int nodeLevel, int currentCareerLevel) {
    bool isLocked = nodeLevel > currentCareerLevel;
    bool isCurrent = nodeLevel == currentCareerLevel;

    // YENİ: Geçici Set yerine doğrudan kalıcı DataManager'dan soruyoruz! (GLITCH FİXLENDİ)
    bool isClaimed = DataManager.isRewardClaimed(nodeLevel);

    bool isBoss = nodeLevel % 10 == 0;
    bool isReward = nodeLevel % 5 == 0;

    // Yılan kıvrımı (Sinüs dalgası) matematiği
    double offsetX = sin(nodeLevel * 0.5) * 80;
    double nextOffsetX = sin((nodeLevel - 1) * 0.5) * 80;

    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // A) KIVRIMLI YOL ÇİZGİSİ
          if (nodeLevel > 1)
            CustomPaint(
              size: const Size(double.infinity, 120),
              painter: PathPainter(
                  startX: offsetX, endX: nextOffsetX, isLocked: isLocked),
            ),

          // B) LEVEL DÜĞÜMÜ (Tıklanabilir)
          Transform.translate(
            offset: Offset(offsetX, 0),
            child: GestureDetector(
              onTap: () {
                if (isLocked) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Bu seviyeye henüz ulaşmadın! 🔒"),
                      duration: Duration(milliseconds: 500),
                      backgroundColor: Colors.redAccent));
                } else if (isClaimed) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Bu ödülü zaten aldın! ✅"),
                      duration: Duration(milliseconds: 500)));
                } else {
                  // Her düğüme tıklayıp ödül alabilir. Reward ve Boss levellerde daha çok verir.
                  _showPremiumRewardDialog(nodeLevel);
                }
              },
              child: _buildNodeContent(
                  nodeLevel, isLocked, isCurrent, isClaimed, isBoss, isReward),
            ),
          ),

          // C) YAN BİLGİ METNİ (Seviye Numarası)
          Transform.translate(
            offset: Offset(offsetX + (offsetX > 0 ? -60 : 60), 0),
            child: Text("$nodeLevel",
                style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.white24,
                    fontSize: isCurrent ? 26 : 16,
                    fontWeight: FontWeight.w900)),
          )
        ],
      ),
    );
  }

  // --- DÜĞÜM (NODE) GÖRSELİ ---
  Widget _buildNodeContent(int level, bool isLocked, bool isCurrent,
      bool isClaimed, bool isBoss, bool isReward) {
    double size = isBoss ? 80 : 60;

    Color color = isLocked
        ? Colors.grey.shade800
        : (isClaimed
            ? Colors.green.shade900
            : (isBoss ? Colors.redAccent.shade700 : Colors.cyan.shade700));
    IconData icon = isLocked
        ? Icons.lock_rounded
        : (isClaimed
            ? Icons.check_rounded
            : (isReward
                ? Icons.card_giftcard_rounded
                : Icons.play_arrow_rounded));

    // Claim edilebilir durumdaysa (Geçilmiş ama ödülü alınmamış)
    bool isClaimable = !isLocked && !isClaimed;

    return TweenAnimationBuilder<double>(
      tween: Tween(
          begin: 1.0,
          end: isClaimable
              ? 1.15
              : 1.0), // Ödülü alınmadıysa kalp gibi atar/büyür
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
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 5,
                            offset: const Offset(0, 5))
                      ]),
            child: Icon(icon, color: Colors.white, size: size * 0.5),
          ),
        );
      },
    );
  }
}

// ==========================================
// YILAN (S-SHAPE) YOL ÇİZİCİSİ
// ==========================================
class PathPainter extends CustomPainter {
  final double startX;
  final double endX;
  final bool isLocked;

  PathPainter(
      {required this.startX, required this.endX, required this.isLocked});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          isLocked ? Colors.white10 : Colors.cyanAccent.withValues(alpha: 0.5)
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
