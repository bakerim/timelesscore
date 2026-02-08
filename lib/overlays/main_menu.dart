import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../game/timeless_game.dart';
import '../core/localization.dart';
import '../core/constants.dart' as Core;
import '../data/progress_manager.dart';
import '../data/data_manager.dart';

class AnaMenuOverlay extends StatefulWidget {
  final TimelessGame game;
  const AnaMenuOverlay({super.key, required this.game});

  @override
  State<AnaMenuOverlay> createState() => _AnaMenuOverlayState();
}

class _AnaMenuOverlayState extends State<AnaMenuOverlay>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _rotationController;
  late AnimationController _entryController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();

    _logoController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.easeInOut));

    _rotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();

    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _blurAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
        CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));

    _entryController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _rotationController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Animation<Offset> _createSlideAnim(double start, double end) {
    return Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(
            parent: _entryController,
            curve: Interval(start, end, curve: Curves.easeOutBack)));
  }

  Animation<double> _createFadeAnim(double start, double end) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _entryController,
        curve: Interval(start, end, curve: Curves.easeIn)));
  }

  @override
  Widget build(BuildContext context) {
    final pm = ProgressManager();
    double progressValue = (pm.xp / pm.nextLevelXp(pm.level)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: _blurAnimation.value, sigmaY: _blurAnimation.value),
                child: Container(
                    color: Colors.black
                        .withOpacity(0.4 * (_blurAnimation.value / 8.0))),
              );
            },
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _createFadeAnim(0.0, 0.4),
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotationController.value * 2 * math.pi,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(colors: [
                                      Colors.cyanAccent.withOpacity(0.2),
                                      Colors.transparent
                                    ]),
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildLogoIcon(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: _createSlideAnim(0.2, 0.6),
                    child: FadeTransition(
                      opacity: _createFadeAnim(0.2, 0.6),
                      child: _buildProfileCard(pm, progressValue),
                    ),
                  ),
                  const SizedBox(height: 50),
                  SlideTransition(
                    position: _createSlideAnim(0.4, 0.8),
                    child: FadeTransition(
                      opacity: _createFadeAnim(0.4, 0.8),
                      child: _buildPlayButton(),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SlideTransition(
                    position: _createSlideAnim(0.6, 1.0),
                    child: FadeTransition(
                      opacity: _createFadeAnim(0.6, 1.0),
                      child: _buildSecondaryButtons(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _createFadeAnim(0.8, 1.0),
                    child: Text(
                      "${Dil.get("rekor")}: ${DataManager.highScore}",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 16,
                          letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoIcon() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
          ),
          child: const Icon(Icons.hourglass_empty_rounded,
              size: 70, color: Colors.cyanAccent),
        ),
        const SizedBox(height: 15),
        const Text(
          "TIMELESS",
          style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 8,
              shadows: [Shadow(color: Colors.cyan, blurRadius: 20)]),
        ),
        Text(
          "CORE",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 12),
        ),
      ],
    );
  }

  Widget _buildProfileCard(ProgressManager pm, double progress) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.cyanAccent,
            radius: 24,
            child: Text("${pm.level}",
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Dil.get(pm.rankName.toLowerCase()),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white10,
                    color: Colors.cyanAccent,
                    minHeight: 7,
                  ),
                ),
                const SizedBox(height: 5),
                Text("${pm.xp} / ${pm.nextLevelXp(pm.level)} XP",
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: () => widget.game.oyunuBaslat(),
      child: Container(
        width: 280,
        height: 75,
        decoration: BoxDecoration(
          color: Core.Tasarim.playButton,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.greenAccent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 35),
            const SizedBox(width: 12),
            Text(
              Dil.get("basla"),
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _smallBtn(
            Dil.get("yol_haritasi"), Icons.map_outlined, Colors.purpleAccent,
            () {
          widget.game.overlays.remove('AnaMenu');
          widget.game.overlays.add('Roadmap');
        }),
        const SizedBox(width: 20),
        _smallBtn(
            Dil.get("ayarlar"), Icons.settings_outlined, Colors.amberAccent,
            () {
          widget.game.overlays.add('Ayarlar');
        }),
      ],
    );
  }

  Widget _smallBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
