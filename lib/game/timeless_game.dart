import 'dart:math';
import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart' as core;
import '../data/data_manager.dart';
import '../data/progress_manager.dart';
import '../data/purchase_manager.dart';
import 'ad_manager.dart';
import '../core/audio_manager.dart';
import '../core/theme_manager.dart';

import 'components/kare.dart';
import 'components/star_background.dart';
// Pause_button importu silindi, artık GameHUD içinden yönetiliyor.

class TimelessGame extends FlameGame
    with PanDetector, HasCollisionDetection, TapCallbacks {
  late final AdManager adManager;

  // ESKİ SKOR VE ELMAS YAZILARI SİLİNDİ (Artık Flutter GameHUD yönetiyor)
  late TextComponent comboYazisi;
  Kare? oyuncu;

  // --- OYUN AYARLARI ---
  final double gridSize = 50.0;
  final double hudHeight = 110.0; // Ferah oyun alanı
  final double safeBottomArea = 100.0;
  final Random _rng = Random();

  double sayac = 0;
  double normalOyunHizi = core.GameConfig.initialSpeedMs / 1000.0;
  double oyunHizi = core.GameConfig.initialSpeedMs / 1000.0;

  bool isTimeSlowed = false;
  double _slowMoOpacity = 0.0;
  final Paint _timeWarpPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 12
    ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 15);

  int skor = 0, comboSayaci = 0, buOyunKazanilanKristal = 0, currentLevel = 1;
  bool isGameOver = false,
      isPaused = true,
      isReviveScreenOpen = false,
      reviveUsed = false;

  // --- KAYDIRMA HASSASİYETİ ---
  double suruklemeBirikimiX = 0, suruklemeBirikimiY = 0;
  bool dropLock = false;

  final Paint slotPaint = Paint()
    ..color = const Color.fromARGB(12, 255, 255, 255)
    ..style = PaintingStyle.fill;

  GameTheme get currentTheme => ThemeManager.getTheme(DataManager.activeTheme);

  @override
  Color backgroundColor() => currentTheme.bgCenterColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await DataManager.init();
    await ProgressManager().init();
    PurchaseManager.init();
    await AudioManager.init();

    adManager = AdManager();
    await adManager.init();

    _buildUI();
    add(StarBackground(size)..priority = 0);
    pauseEngine();
  }

  void _buildUI() {
    // HUD arka planı
    add(RectangleComponent(
        position: Vector2(0, 0),
        size: Vector2(size.x, hudHeight),
        paint: Paint()..color = const Color(0xFF1E293B).withValues(alpha: 0.6),
        priority: 5));

    comboYazisi = TextComponent(
        text: '',
        textRenderer: TextPaint(
            style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 24,
                fontWeight: FontWeight.w900)),
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        priority: 20);

    add(comboYazisi);
  }

  @override
  void render(Canvas canvas) {
    double sy = hudHeight + 10, ey = size.y - safeBottomArea;
    int r = ((ey - sy) / gridSize).floor(), col = (size.x / gridSize).floor();
    double off = (size.x - col * gridSize) / 2;

    for (int i = 0; i < col; i++) {
      for (int j = 0; j < r; j++) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(off + i * gridSize + 5, sy + j * gridSize + 5,
                    gridSize - 10, gridSize - 10),
                const Radius.circular(10)),
            slotPaint);
      }
    }

    if (isTimeSlowed) {
      _slowMoOpacity =
          0.2 + (sin(DateTime.now().millisecondsSinceEpoch / 200) * 0.15);
      _timeWarpPaint.color = currentTheme.starColor
          .withValues(alpha: _slowMoOpacity.clamp(0.0, 1.0));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _timeWarpPaint);
    }
    super.render(canvas);
  }

  void hizliIndir(Kare k) {
    int dusulenBosluk = 0;
    while (!carpismaVarMi(k.position.x, k.position.y + gridSize)) {
      k.position.y += gridSize;
      dusulenBosluk++;
    }

    if (dusulenBosluk > 0) {
      puanEkle(dusulenBosluk);
      _showFloatingText("+$dusulenBosluk", Colors.white70, hizli: true);
    }
    blokKatilastir(k, hizliIndiMi: true);
  }

  void blokKatilastir(Kare k, {bool hizliIndiMi = false}) {
    k.tur = "duvar";
    try {
      AudioManager.playSfx('sfx/drop.mp3');
    } catch (e) {}

    if (!hizliIndiMi) {
      puanEkle(1);
    }

    if (!isTimeSlowed) {
      oyunHizi = normalOyunHizi;
    }

    if (k.position.y <= hudHeight + gridSize) {
      carpismaSonrasiKontrol();
      return;
    }

    bool temizlendi = satirTemizle();
    if (!temizlendi) {
      comboSayaci = 0;
      comboYazisi.text = '';
    }

    oyuncu = null;
    spawnOyuncu();
  }

  bool satirTemizle() {
    List<Kare> duvarlar = children
        .whereType<Kare>()
        .where((k) => k.tur == "duvar" && !k.isRemoving)
        .toList();
    if (duvarlar.isEmpty) return false;

    Map<int, List<Kare>> satirlar = {};
    for (var k in duvarlar) {
      satirlar.putIfAbsent((k.position.y).round(), () => []).add(k);
    }

    int cols = (size.x / gridSize).floor();
    List<int> doluSatirlar = [];
    satirlar.forEach((y, bloklar) {
      if (bloklar.length >= cols) doluSatirlar.add(y);
    });

    if (doluSatirlar.isEmpty) return false;

    int kazanilanPuan = 0;
    for (int i = 0; i < doluSatirlar.length; i++) {
      comboSayaci++;
      kazanilanPuan += (comboSayaci * 100);
    }
    puanEkle(kazanilanPuan);

    if (comboSayaci > 1) {
      comboYazisi.text = 'COMBO x$comboSayaci';
      comboYazisi.add(ScaleEffect.by(Vector2.all(1.2),
          EffectController(duration: 0.1, reverseDuration: 0.1)));
      _showFloatingText("+$kazanilanPuan", Colors.amberAccent);
    }

    try {
      AudioManager.playSfx('sfx/clear.mp3');
    } catch (e) {}

    if (!kIsWeb) HapticFeedback.heavyImpact();

    for (int y in doluSatirlar) {
      for (var k in satirlar[y]!) {
        k.isRemoving = true;
        k.add(ScaleEffect.to(Vector2.all(0.0),
            EffectController(duration: 0.3, curve: Curves.easeInBack),
            onComplete: () => k.removeFromParent()));
      }
    }

    doluSatirlar.sort();
    add(TimerComponent(
        period: 0.1,
        removeOnFinish: true,
        onTick: () {
          for (var k in duvarlar) {
            if (k.isRemoving) continue;
            int kayma = doluSatirlar.where((y) => k.position.y < y).length;
            if (kayma > 0) {
              k.position.y += kayma * gridSize;
              k.add(MoveEffect.by(Vector2.zero(),
                  EffectController(duration: 0.2, curve: Curves.bounceOut)));
            }
          }
        }));
    return true;
  }

  void puanEkle(int miktar) {
    skor += miktar;
    // skorYazisi.text = '$skor'; SATIRI SİLİNDİ

    ProgressManager().addXp(miktar);

    if (skor % 5000 < miktar) {
      DataManager.totalCoins += 1;
      buOyunKazanilanKristal += 1;
      DataManager.saveData();
      // elmasYazisi.text = ... SATIRI SİLİNDİ
      _showFloatingText("+1 KRİSTAL", Colors.cyanAccent);
    }

    int yeniLevel = (skor / 1000).floor() + 1;
    if (yeniLevel > currentLevel) {
      currentLevel = yeniLevel;
      normalOyunHizi = max(0.08, normalOyunHizi * 0.93);
      if (!isTimeSlowed) {
        oyunHizi = normalOyunHizi;
      }
      try {
        AudioManager.playSfx('sfx/level_up.mp3');
      } catch (e) {}
    }
  }

  void anaMenuyeDon() {
    children.whereType<Kare>().forEach((k) => k.removeFromParent());
    overlays.clear();
    skor = 0;
    currentLevel = 1;
    comboSayaci = 0;
    comboYazisi.text = '';
    reviveUsed = false;
    isGameOver = false;
    buOyunKazanilanKristal = 0;
    isPaused = true;
    pauseEngine();

    AudioManager.manageBgm(false);
    overlays.add('AnaMenu');
  }

  // --- TELEFON FİZİKSEL GERİ TUŞU YÖNETİMİ ---
  bool onBackPressed() {
    // 1. Ekstra menüler açıksa onları kapat
    if (overlays.isActive('Roadmap')) {
      overlays.remove('Roadmap');
      return false;
    } else if (overlays.isActive('ShopMenu')) {
      overlays.remove('ShopMenu');
      return false;
    } else if (overlays.isActive('ThemeMenu')) {
      overlays.remove('ThemeMenu');
      return false;
    } else if (overlays.isActive('DailySpin')) {
      overlays.remove('DailySpin');
      return false;
    } else if (overlays.isActive('SettingsMenu')) {
      overlays.remove('SettingsMenu');
      if (isPaused && !overlays.isActive('GameHUD')) {
        overlays.add('AnaMenu');
      }
      return false;
    }
    // 2. Ana Menü açıksa uygulamadan çıkmasına izin ver
    else if (overlays.isActive('AnaMenu')) {
      return true;
    }
    // 3. Oyun oynanıyorsa, duraklatma menüsünü (Pause) açar
    else if (overlays.isActive('GameHUD')) {
      togglePause();
      return false;
    }
    // 4. Oyun zaten duraklatılmışsa, geri tuşuna basınca oyuna devam eder
    else if (overlays.isActive('PauseMenu')) {
      togglePause();
      return false;
    }

    return false;
  }

  void oyunuBaslat() {
    children.whereType<Kare>().forEach((k) => k.removeFromParent());
    overlays.clear();
    skor = 0;
    comboSayaci = 0;
    comboYazisi.text = '';
    buOyunKazanilanKristal = 0;
    reviveUsed = false;
    isGameOver = false;
    isTimeSlowed = false;

    normalOyunHizi = core.GameConfig.initialSpeedMs / 1000.0;
    oyunHizi = normalOyunHizi;

    overlays.add('GameHUD');
    isPaused = false;
    resumeEngine();

    AudioManager.resumeBgm();

    Future.delayed(
        const Duration(milliseconds: 200), () => spawnOyuncu(zorla: true));
  }

  void spawnOyuncu({bool zorla = false}) {
    if (isGameOver || isPaused || isReviveScreenOpen) return;

    oyuncu = Kare(gridSize, bazRenk: _getLevelBasedColor(), tur: "oyuncu");
    oyuncu!.position = Vector2(
        ((size.x - ((size.x / gridSize).floor() * gridSize)) / 2) +
            ((size.x / gridSize).floor() / 2).floor() * gridSize,
        hudHeight + 10);
    add(oyuncu!);
  }

  void yercekimiAdimi() {
    if (oyuncu == null) return;
    if (carpismaVarMi(oyuncu!.position.x, oyuncu!.position.y + gridSize)) {
      blokKatilastir(oyuncu!);
    } else {
      oyuncu!.position.y += gridSize;
    }
  }

  bool carpismaVarMi(double x, double y) {
    if (y >= size.y - safeBottomArea - gridSize) return true;
    return children.any((c) =>
        c is Kare &&
        c.tur == "duvar" &&
        !c.isRemoving &&
        (c.position.x - x).abs() < 5 &&
        (c.position.y - y).abs() < 5);
  }

  void togglePause() {
    isPaused = !isPaused;
    if (isPaused) {
      overlays.add('PauseMenu');
      pauseEngine();
      AudioManager.pauseBgm();
    } else {
      overlays.remove('PauseMenu');
      resumeEngine();
      AudioManager.resumeBgm();
    }
  }

  void manuelZamanYavaslat() {
    if (isGameOver || isPaused || isTimeSlowed || isReviveScreenOpen) return;
    const int maliyet = 5;
    if (DataManager.totalCoins >= maliyet) {
      DataManager.totalCoins -= maliyet;
      DataManager.saveData();

      isTimeSlowed = true;
      oyunHizi = normalOyunHizi * 3.5;

      try {
        AudioManager.playSfx('sfx/slow_motion.mp3');
      } catch (e) {}

      add(TimerComponent(
          period: 5.0,
          removeOnFinish: true,
          onTick: () {
            isTimeSlowed = false;
            if (!isPaused) oyunHizi = normalOyunHizi;
          }));
    }
  }

  void reklamIzleVeCanlan() {
    adManager.showRewardedAd(
        onReward: (amount) => devamEtIslemi(),
        onAdFailed: () {
          debugPrint("Reklam hatası, ama oyuncu canlandırılıyor.");
          devamEtIslemi();
        });
  }

  void altSatirlariTemizle() {
    children.whereType<Kare>().where((k) => k.tur == "duvar").forEach((k) {
      k.removeFromParent();
    });
  }

  void devamEtIslemi() {
    overlays.remove('ReviveMenu');
    isReviveScreenOpen = false;
    reviveUsed = true;
    altSatirlariTemizle();
    isGameOver = false;
    isPaused = false;
    resumeEngine();
    spawnOyuncu(zorla: true);
    overlays.add('GameHUD');
  }

  void vazgecVeBitir() {
    isReviveScreenOpen = false;
    oyunuBitir();
  }

  Future<void> oyunuBitir() async {
    if (isGameOver) return;

    isGameOver = true;
    isPaused = true;

    await DataManager.saveScore(skor);
    AudioManager.manageBgm(false);
    pauseEngine();

    adManager.showInterstitialAd(
      onAdDismissed: () {
        overlays.remove('GameHUD');
        overlays.add('GameOver');
        if (oyuncu != null) {
          oyuncu!.removeFromParent();
          oyuncu = null;
        }
      },
    );
  }

  void carpismaSonrasiKontrol() {
    if (!reviveUsed && skor > 100) {
      isPaused = true;
      pauseEngine();
      isReviveScreenOpen = true;
      overlays.remove('GameHUD');
      overlays.add('ReviveMenu');
    } else {
      oyunuBitir();
    }
  }

  Color _getLevelBasedColor() {
    final List<Color> themeColors = currentTheme.blockColors;
    return themeColors[_rng.nextInt(themeColors.length)];
  }

  void _showFloatingText(String text, Color color, {bool hizli = false}) {
    final textComp = TextComponent(
        text: text,
        textRenderer: TextPaint(
            style: TextStyle(
                color: color,
                fontSize: hizli ? 18 : 28,
                fontWeight: FontWeight.w900,
                shadows: const [Shadow(blurRadius: 10, color: Colors.black)])),
        position: size / 2,
        anchor: Anchor.center);
    add(textComp);
    textComp.add(MoveEffect.by(Vector2(0, hizli ? -50 : -150),
        EffectController(duration: hizli ? 0.6 : 1.2),
        onComplete: () => textComp.removeFromParent()));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver || isPaused || isReviveScreenOpen) return;
    sayac += dt;
    if (sayac > oyunHizi) {
      sayac = 0;
      yercekimiAdimi();
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isGameOver || isPaused || oyuncu == null) return;

    if (info.delta.global.x.abs() > info.delta.global.y.abs()) {
      suruklemeBirikimiX += info.delta.global.x;
      if (suruklemeBirikimiX.abs() >= gridSize * 0.7) {
        _hareketEt(oyuncu!, suruklemeBirikimiX.sign.toInt());
        suruklemeBirikimiX = 0;
      }
      suruklemeBirikimiY = 0;
    } else {
      suruklemeBirikimiY += info.delta.global.y;
      if (suruklemeBirikimiY > 35 && !dropLock) {
        dropLock = true;
        hizliIndir(oyuncu!);
        suruklemeBirikimiY = 0;
      }
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    dropLock = false;
    suruklemeBirikimiX = 0;
    suruklemeBirikimiY = 0;
  }

  @override
  void onPanCancel() {
    dropLock = false;
    suruklemeBirikimiX = 0;
    suruklemeBirikimiY = 0;
  }

  void _hareketEt(Kare k, int dx) {
    double nx = k.position.x + dx * gridSize;
    if (nx >= 0 &&
        nx <= size.x - gridSize &&
        !carpismaVarMi(nx, k.position.y)) {
      k.position.x = nx;
      try {
        AudioManager.playSfx('sfx/drop.mp3');
      } catch (e) {}
    }
  }

  @override
  void onRemove() {
    AudioManager.dispose();
    adManager.disposeAds();
    super.onRemove();
  }
}
