import 'package:flutter/material.dart';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';
import '../core/theme_manager.dart';

class ThemeMenu extends StatefulWidget {
  final TimelessGame game;
  const ThemeMenu({super.key, required this.game});

  @override
  State<ThemeMenu> createState() => _ThemeMenuState();
}

class _ThemeMenuState extends State<ThemeMenu> {
  int _currentCoins = 0;

  @override
  void initState() {
    super.initState();
    _currentCoins = DataManager.totalCoins;
  }

  void _updateUI() {
    setState(() {
      _currentCoins = DataManager.totalCoins;
    });
  }

  void _kapat() {
    widget.game.overlays.remove('ThemeMenu');
    // Eğer oyundayken değil de ana menüdeyken açıldıysa, geri ana menüye dönsün:
    if (widget.game.isPaused && !widget.game.overlays.isActive('GameHUD')) {
      widget.game.overlays.add('AnaMenu');
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleThemeTap(GameTheme theme) async {
    bool isUnlocked = DataManager.unlockedThemes.contains(theme.id);
    bool isActive = DataManager.activeTheme == theme.id;

    if (isActive) {
      _showSnack("Bu tema zaten kullanımda!", Colors.blueAccent);
      return;
    }

    if (isUnlocked) {
      // Temayı Kullan
      await DataManager.setActiveTheme(theme.id);
      _updateUI();
      _showSnack("${theme.name} teması uygulandı!", Colors.green);
    } else {
      // Satın Alma İşlemi
      if (_currentCoins >= theme.price) {
        DataManager.totalCoins -= theme.price;
        await DataManager.unlockTheme(theme.id);
        await DataManager.setActiveTheme(theme.id);
        DataManager.saveData(); // Cüzdanı kaydet
        _updateUI();

        _showSnack(
            "${theme.name} açıldı! Kristallerin eksildi.", Colors.purpleAccent);
      } else {
        // --- GARANTİCİ TUZAK: Yetersiz bakiyede doğrudan Markete Yönlendir ---
        _showSnack("Yetersiz Kristal! Markete yönlendiriliyorsunuz.",
            Colors.redAccent);
        Future.delayed(const Duration(milliseconds: 1000), () {
          widget.game.overlays.remove('ThemeMenu');
          widget.game.overlays.add('ShopMenu');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Glassmorphism Arka Plan
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(color: Colors.black.withValues(alpha: 0.85)),
          ),

          Center(
            child: Container(
              width: 380,
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.3),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.1),
                      blurRadius: 30,
                      spreadRadius: 5)
                ],
              ),
              child: Column(
                children: [
                  // --- ÜST BİLGİ KISMI ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("TEMALAR",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5)),
                          Text("Tarzını belirle",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.cyanAccent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.diamond,
                                color: Colors.cyanAccent, size: 20),
                            const SizedBox(width: 8),
                            Text("$_currentCoins",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 25),

                  // --- TEMA LİSTESİ ---
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: ThemeManager.availableThemes.length,
                      itemBuilder: (context, index) {
                        GameTheme theme = ThemeManager.availableThemes[index];
                        bool isUnlocked =
                            DataManager.unlockedThemes.contains(theme.id);
                        bool isActive = DataManager.activeTheme == theme.id;

                        return _buildThemeCard(theme, isUnlocked, isActive);
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  // --- KAPAT BUTONU (Minimalist) ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: _kapat,
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white54,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close_rounded),
                          SizedBox(width: 8),
                          Text("KAPAT",
                              style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
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

  Widget _buildThemeCard(GameTheme theme, bool isUnlocked, bool isActive) {
    return GestureDetector(
      onTap: () => _handleThemeTap(theme),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          // DEĞİŞİKLİK: Siyah temaların görünmez olmasını engellemek için hafif bir degrade (gradient) eklendi
          gradient: LinearGradient(
            colors: [
              theme.bgCenterColor,
              theme.bgCenterColor.withValues(alpha: 0.5),
              Colors.black54,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Colors.white
                : theme.blockColors.first.withValues(alpha: 0.3),
            width: isActive ? 3 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: theme.blockColors.first.withValues(alpha: 0.5),
                      blurRadius: 15)
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sol Taraf: Renk Paleti ve İsim
            Row(
              children: [
                // Mini Renk Paleti Önizlemesi
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    children: [
                      Positioned(
                          left: 0,
                          top: 0,
                          child: _buildColorDot(theme.blockColors[0])),
                      Positioned(
                          right: 0,
                          top: 0,
                          child: _buildColorDot(
                              theme.blockColors[1 % theme.blockColors.length])),
                      Positioned(
                          left: 0,
                          bottom: 0,
                          child: _buildColorDot(
                              theme.blockColors[2 % theme.blockColors.length])),
                      Positioned(
                          right: 0,
                          bottom: 0,
                          child: _buildColorDot(
                              theme.blockColors[3 % theme.blockColors.length])),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(theme.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                    Text(
                      isActive
                          ? "AKTİF"
                          : (isUnlocked ? "SAHİP OLUNDU" : "KİLİTLİ"),
                      style: TextStyle(
                        color: isActive
                            ? Colors.greenAccent
                            : (isUnlocked ? Colors.white54 : Colors.redAccent),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Sağ Taraf: Fiyat veya Seç Butonu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : (isUnlocked
                        ? Colors.white24
                        : Colors.amberAccent.shade700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isActive
                  ? const Icon(Icons.check_circle,
                      color: Colors.green, size: 24)
                  : (isUnlocked
                      ? const Text("SEÇ",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))
                      : Row(
                          children: [
                            Text("${theme.price}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16)),
                            const SizedBox(width: 5),
                            const Icon(Icons.diamond,
                                color: Colors.white, size: 16),
                          ],
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1)),
    );
  }
}
