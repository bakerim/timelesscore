import 'dart:math';
import 'dart:async'; // Dart'ın standart Timer sınıfı
import 'package:flame/game.dart';
import 'package:flame/components.dart' hide Timer; // Flame Timer'ı gizle
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// --- KENDİ DOSYALARIMIZ ---
import '../core/constants.dart' as Core;
import '../core/localization.dart';
import '../data/data_manager.dart';
import '../data/progress_manager.dart';
import 'components/kare.dart';
import 'components/pause_button.dart';
import 'components/reward.dart'; // RewardType buradan geliyor
import 'components/star_background.dart';
import 'ad_manager.dart';

enum AdPurpose { revive, doubleScore, none }

class TimelessGame extends FlameGame
    with PanDetector, TapDetector, HasCollisionDetection {
  // --- REKLAM YÖNETİCİSİ ---
  late final AdManager adManager;

  // --- UI BİLEŞENLERİ ---
  late TextComponent skorYazisi;
  // late TextComponent elmasYazisi; // ARTIK GameHUD İÇİNDE, BURADA GEREK YOK AMA REFERANS HATASI OLMASIN DİYE AŞAĞIDA TANIMLAYIP EKLEMEYECEĞİZ.
  late TextComponent elmasYazisi;
  late TextComponent yuksekSkorYazisi;
  late TextComponent comboYazisi;
  late TextComponent levelYazisi;
  late Kare oyuncu;

  // --- AYARLAR ---
  final double gridSize = 50.0;
  final double hudHeight = 160.0;
  final double safeBottomArea = 100.0;
  final Random _rng = Random();

  // --- OYUN DURUMU ---
  double sayac = 0;
  double oyunHizi = Core.GameConfig.initialSpeedMs / 1000.0;
  bool isTimeSlowed = false;

  int currentLevel = 1;
  int skor = 0;
  int comboSayaci = 0;
  int buOyunKazanilanKristal = 0;
  double rewardSpawnTimer = 0;

  // --- KONTROL BAYRAKLARI ---
  bool isGameOver = false;
  bool isPaused = true;
  bool sesAcik = true;
  bool muzikAcik = true;
  bool isReviveScreenOpen = false;
  bool reviveUsed = false;

  // --- ETKİLEŞİM ---
  double suruklemeBirikimiX = 0;
  double suruklemeBirikimiY = 0;
  bool dropLock = false;

  final Paint slotPaint = Paint()
    ..color = Colors.white.withOpacity(0.05)
    ..style = PaintingStyle.fill;

  @override
  Color backgroundColor() => const Color(0xFF0F172A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Veri ve reklam yöneticilerini başlat
    await DataManager.init();
    await ProgressManager().init();

    // AdManager Başlatma
    adManager = AdManager();
    await adManager.init();

    if (!kIsWeb) {
      adManager.loadRewardedAd();
    }

    // UI Elemanlarını Oluştur
    _buildUI();

    // Başlangıç ayarları
    pauseEngine();
  }

  void _buildUI() {
    // Üst Panel (HUD) Arkaplanı
    add(RectangleComponent(
        position: Vector2(0, 0),
        size: Vector2(size.x, hudHeight),
        paint: Paint()..color = Core.Tasarim.arkaPlan.withOpacity(0.9),
        priority: 5));

    levelYazisi = TextComponent(
      text: 'LVL 1',
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Colors.orangeAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
      position: Vector2(size.x - 90, 50),
      anchor: Anchor.topRight,
      priority: 10,
    );

    skorYazisi = TextComponent(
      text: '0',
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Colors.white, fontSize: 50, fontWeight: FontWeight.w900)),
      position: Vector2(size.x / 2, 45),
      anchor: Anchor.topCenter,
      priority: 10,
    );

    // NOT: Elmas yazısını oluşturuyoruz ki kodun başka yerlerinde hata vermesin
    // AMA ekrana (add) etmiyoruz. Çünkü artık GameHUD kullanıyoruz.
    elmasYazisi = TextComponent(
      text: '💎 ${DataManager.totalCoins}',
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Colors.transparent, // Görünmez yapıyoruz
              fontSize: 1)),
      position: Vector2(-100, -100), // Ekran dışına atıyoruz
    );

    yuksekSkorYazisi = TextComponent(
      text: '${Dil.get("rekor")}: ${DataManager.highScore}',
      textRenderer: TextPaint(
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
      position: Vector2(size.x / 2, 100),
      anchor: Anchor.topCenter,
      priority: 10,
    );

    comboYazisi = TextComponent(
      text: '',
      textRenderer: TextPaint(
          style: TextStyle(
              color: Core.Tasarim.renkler[3],
              fontSize: 30,
              fontWeight: FontWeight.bold)),
      position: Vector2(size.x / 2, hudHeight + 50),
      anchor: Anchor.center,
      priority: 20,
    );

    add(StarBackground(size)..priority = 0);
    // add(SlowButton(...)); // ARTIK YOK, HUD İÇİNDE

    add(PauseButton(
        position: Vector2(size.x - 40, 60), onTapAction: togglePause));

    add(levelYazisi);
    add(skorYazisi);
    // add(elmasYazisi); // EKLEMİYORUZ (HUD hallediyor)
    add(yuksekSkorYazisi);
    add(comboYazisi);

    // --- YENİ EKLENEN KOKPİT (HUD) ---
    overlays.add('GameHUD');
  }

  // --- YAŞAM DÖNGÜSÜ & SES ---
  @override
  void lifecycleStateChange(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && !isPaused && !isGameOver) {
      togglePause();
    }
    super.lifecycleStateChange(state);
  }

  void muzikYonetimi(bool ac) {
    muzikAcik = ac;
    if (ac && !FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.play('sfx/move.mp3', volume: 0.25);
    } else if (!ac) {
      FlameAudio.bgm.stop();
    }
  }

  void sesCal(String dosyaAdi) {
    if (sesAcik) {
      FlameAudio.play(dosyaAdi).then((_) {}, onError: (e) {
        debugPrint("Ses hatası: $e");
      });
    }
  }

  @override
  void onRemove() {
    FlameAudio.bgm.dispose();
    adManager.disposeAds();
    super.onRemove();
  }

  // --- DURAKLATMA / GERİ TUŞU ---
  void togglePause() {
    if (isGameOver || isReviveScreenOpen) return;
    isPaused = !isPaused;
    if (isPaused) {
      overlays.add('PauseMenu');
      // HUD'ı durdurunca gizlemek isteyebilirsin, ama genelde kalabilir.
      // overlays.remove('GameHUD');
      pauseEngine();
      FlameAudio.bgm.pause();
    } else {
      overlays.remove('PauseMenu');
      // overlays.add('GameHUD');
      resumeEngine();
      if (muzikAcik) muzikYonetimi(true);
    }
  }

  bool onBackPressed() {
    if (overlays.isActive('AnaMenu')) return true;
    if (!isPaused && !isGameOver) {
      togglePause();
    } else if (isPaused && overlays.isActive('PauseMenu')) {
      anaMenuyeDon();
    }
    return false;
  }

  // --- OYUN AKIŞI ---
  void anaMenuyeDon() {
    _resetGame(showMainMenu: true);
  }

  void oyunuBaslat() {
    _resetGame();
    Future.delayed(
        const Duration(milliseconds: 100), () => spawnOyuncu(zorla: true));
  }

  void _resetGame({bool showMainMenu = false}) {
    // Tüm oyun nesnelerini temizle
    children.whereType<Kare>().forEach((k) => k.removeFromParent());
    children.whereType<OdulParcacigi>().forEach((o) => o.removeFromParent());
    children
        .whereType<ParticleSystemComponent>()
        .forEach((p) => p.removeFromParent());

    // Tüm menüleri temizle
    overlays.clear();

    // HUD her zaman açık olmalı (Oyun içindeyken)
    // Ama Ana Menüye dönüyorsak HUD kapanmalı

    if (showMainMenu) {
      overlays.add('AnaMenu');
      isPaused = true;
      pauseEngine();
      FlameAudio.bgm.stop();
    } else {
      overlays.add('GameHUD'); // Oyuna başlarken HUD'ı aç
      isPaused = false;
      resumeEngine();
      if (muzikAcik) muzikYonetimi(true);
    }

    // Değişkenleri sıfırla
    skor = 0;
    skorYazisi.text = '0';
    comboSayaci = 0;
    comboYazisi.text = '';
    buOyunKazanilanKristal = 0;
    rewardSpawnTimer = 0;
    currentLevel = 1;
    levelYazisi.text = 'LVL 1';
    oyunHizi = Core.GameConfig.initialSpeedMs / 1000.0;
    isGameOver = false;
    isReviveScreenOpen = false;
    reviveUsed = false;
    isTimeSlowed = false;
  }

  Future<void> oyunuBitir() async {
    if (isGameOver) return;
    isGameOver = true;
    isPaused = true;
    sesCal('sfx/gameover.mp3');
    FlameAudio.bgm.stop();

    await DataManager.saveScore(skor);
    await ProgressManager().addXp(skor);
    yuksekSkorYazisi.text = '${Dil.get("rekor")}: ${DataManager.highScore}';

    // Oyun bitince HUD'ı gizle ki Game Over ekranı temiz görünsün
    overlays.remove('GameHUD');
    overlays.add('GameOver');
    pauseEngine();
  }

  void devamEtIslemi() {
    overlays.remove('ReviveMenu');
    isReviveScreenOpen = false;
    reviveUsed = true;
    altSatirlariTemizle(5);
    if (muzikAcik) muzikYonetimi(true);
    isGameOver = false;
    isPaused = false;
    resumeEngine();
    spawnOyuncu(zorla: true);
    overlays.add('GameHUD'); // HUD geri gelsin
    _showFloatingText("İKİNCİ ŞANS!", Colors.greenAccent);
  }

  void vazgecVeBitir() {
    overlays.remove('ReviveMenu');
    isReviveScreenOpen = false;
    oyunuBitir();
  }

  // --- OYUN MANTIĞI ---
  void spawnOyuncu({bool zorla = false}) {
    if (isGameOver || isPaused || isReviveScreenOpen) return;
    double gridStartY = hudHeight + 20;
    int cols = (size.x / gridSize).floor();
    double baslangicX =
        ((size.x - (cols * gridSize)) / 2) + (cols / 2).floor() * gridSize;
    double baslangicY = gridStartY;

    oyuncu = Kare(gridSize, bazRenk: _getLevelBasedColor(), tur: "oyuncu");
    oyuncu.position = Vector2(baslangicX, baslangicY);
    add(oyuncu);
    suruklemeBirikimiX = 0;
    suruklemeBirikimiY = 0;
  }

  void blokKatilastir(Kare k) {
    sesCal('sfx/drop.mp3');
    titresimYap(agir: true);
    k.tur = "duvar";

    if (k.position.y <= hudHeight + gridSize) {
      carpismaSonrasiKontrol();
      return;
    }

    if (!satirTemizle()) {
      puanEkle(1); // Normal düşüş puanı
      comboSayaci = 0;
      if (!comboYazisi.text.contains("LEVEL")) comboYazisi.text = '';
    }
    spawnOyuncu();
  }

  void carpismaSonrasiKontrol() {
    if (!reviveUsed && skor > 50) {
      isPaused = true;
      pauseEngine();
      isReviveScreenOpen = true;
      overlays.remove('GameHUD'); // Menü açılırken HUD gitsin
      overlays.add('ReviveMenu');
    } else {
      oyunuBitir();
    }
  }

  void puanEkle(int miktar) {
    // 1000 Puan Barajı Kontrolü
    int eskiSkor = skor;
    skor += miktar;
    skorYazisi.text = '$skor';
    _showFloatingText("+$miktar", Colors.amber);

    // Her 1000 puanda 1 Kristal
    if ((skor ~/ 1000) > (eskiSkor ~/ 1000)) {
      int kazanilan = (skor ~/ 1000) - (eskiSkor ~/ 1000);
      DataManager.totalCoins += kazanilan;
      buOyunKazanilanKristal += kazanilan;
      DataManager.saveData();

      // HUD'daki text GameHUD tarafından yönetiliyor ama
      // buradaki dummy text'i de güncelleyelim, ne olur ne olmaz.
      elmasYazisi.text = '💎 ${DataManager.totalCoins}';

      sesCal('sfx/coin.mp3');
      _showFloatingText("+$kazanilan KRİSTAL! 💎", Colors.cyanAccent);
    }

    int yeniLevel = (skor / 750).floor() + 1;
    if (yeniLevel > currentLevel && yeniLevel <= 99) {
      currentLevel = yeniLevel;
      if (!isTimeSlowed) {
        oyunHizi = max(0.05, oyunHizi * 0.94);
      }
      levelYazisi.text = 'LVL $currentLevel';
      _showFloatingText("LEVEL UP!", Colors.orangeAccent);
      sesCal('sfx/level_up.mp3');
    }
  }

  void puanKatla() {
    skor *= 2;
    skorYazisi.text = '$skor';
    _showFloatingText("2X SKOR!", Colors.purpleAccent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver || isPaused || isReviveScreenOpen) return;

    _checkRewardSpawn(dt);
    _checkRewardCollection();

    if (!children.any((c) => c is Kare && c.tur == "oyuncu")) return;

    sayac += dt;
    if (sayac > oyunHizi) {
      sayac = 0;
      yercekimiAdimi();
    }
  }

  void yercekimiAdimi() {
    var oyuncular = children.whereType<Kare>().where((k) => k.tur == "oyuncu");
    if (oyuncular.isEmpty) return;
    Kare k = oyuncular.first;

    if (carpismaVarMi(k.position.x, k.position.y + gridSize)) {
      blokKatilastir(k);
    } else {
      k.position.y += gridSize;
    }
  }

  bool carpismaVarMi(double x, double y) {
    if (y >= size.y - safeBottomArea - gridSize) return true;
    return children.any((c) =>
        c is Kare &&
        c.tur == "duvar" &&
        !c.isRemoving &&
        (c.position.x - x).abs() < 10 &&
        (c.position.y - y).abs() < 30);
  }

  bool satirTemizle() {
    List<Kare> duvarlar = children
        .whereType<Kare>()
        .where((k) => k.tur == "duvar" && !k.isRemoving)
        .toList();

    if (duvarlar.isEmpty) return false;

    Map<int, List<Kare>> satirlar = {};
    for (var k in duvarlar) {
      int yIndex = (k.position.y).round();
      if (!satirlar.containsKey(yIndex)) satirlar[yIndex] = [];
      satirlar[yIndex]!.add(k);
    }

    int cols = (size.x / gridSize).floor();
    List<int> doluSatirlar = [];

    satirlar.forEach((y, bloklar) {
      if (bloklar.length >= cols) {
        doluSatirlar.add(y);
      }
    });

    if (doluSatirlar.isEmpty) return false;

    for (int y in doluSatirlar) {
      for (var k in satirlar[y]!) {
        k.removeFromParent();
        patlamaEfekti(k.position, k.paint.color);
      }
    }

    int temizlenenSatir = doluSatirlar.length;
    // Puan formülü: Satır sayısı arttıkça puan katlanır
    int puan = temizlenenSatir * 100 * temizlenenSatir;
    puanEkle(puan);

    comboSayaci++;
    if (comboSayaci > 1) {
      _showFloatingText("COMBO x$comboSayaci", Colors.cyanAccent);
    }

    sesCal('sfx/clear.mp3');
    titresimYap(agir: true);

    doluSatirlar.sort();
    for (var k in duvarlar) {
      int kaydirmaMiktari = doluSatirlar.where((y) => k.position.y < y).length;
      if (kaydirmaMiktari > 0) {
        k.position.y += kaydirmaMiktari * gridSize;
      }
    }

    return true;
  }

  // --- GÖRSEL FONKSİYONLAR ---
  void _showFloatingText(String text, Color color) {
    debugPrint("EFFECT: $text"); // İlerde buraya Flame TextEffect eklenebilir
  }

  void titresimYap({bool agir = false}) {
    if (!kIsWeb) {
      (agir ? HapticFeedback.heavyImpact() : HapticFeedback.lightImpact());
    }
  }

  void ekranSars(double i) {}

  void patlamaEfekti(Vector2 p, Color c, {bool isBigExplosion = false}) {
    // Parçacık efekti
  }

  void altSatirlariTemizle(int n) {
    List<Kare> duvarlar = children
        .whereType<Kare>()
        .where((k) => k.tur == "duvar" && !k.isRemoving)
        .toList();

    duvarlar.sort((a, b) => b.position.y.compareTo(a.position.y));

    int silinen = 0;
    for (var k in duvarlar) {
      if (silinen < n * (size.x / gridSize).floor()) {
        k.removeFromParent();
        silinen++;
      }
    }
  }

  Color _getLevelBasedColor() {
    List<Color> palet = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.tealAccent,
      Colors.pinkAccent,
      Colors.indigoAccent,
    ];
    int renkCesidi = min(palet.length, 2 + (currentLevel ~/ 2));
    return palet[_rng.nextInt(renkCesidi)];
  }

  // --- ÖDÜL MANTIĞI ---
  void _checkRewardSpawn(double dt) {
    rewardSpawnTimer += dt;
    if (rewardSpawnTimer > 20) {
      rewardSpawnTimer = 0;
      if (_rng.nextDouble() < 0.3) {
        _spawnRandomReward();
      }
    }
  }

  void _spawnRandomReward() {
    double x = _rng.nextDouble() * (size.x - 50);
    double y = hudHeight + 50 + _rng.nextDouble() * (size.y / 2);

    // RewardType.values.first diyerek standart kristal (Crystal) atıyoruz
    // Eğer reward.dart içinde Enum yapın farklıysa burayı güncellemen gerekebilir.
    add(OdulParcacigi(position: Vector2(x, y), type: RewardType.values.first));
  }

  void _checkRewardCollection() {
    var oduller = children.whereType<OdulParcacigi>();
    var oyuncuList = children.whereType<Kare>().where((k) => k.tur == "oyuncu");

    if (oyuncuList.isEmpty || oduller.isEmpty) return;

    Kare p = oyuncuList.first;
    for (var odul in oduller) {
      if (p.toRect().overlaps(odul.toRect())) {
        _collectReward(odul);
      }
    }
  }

  void _collectReward(OdulParcacigi r) {
    r.removeFromParent();
    DataManager.totalCoins++;
    buOyunKazanilanKristal++;
    DataManager.saveData();
    elmasYazisi.text = '💎 ${DataManager.totalCoins}';
    sesCal('sfx/coin.mp3');
    _showFloatingText("+1 Kristal", Colors.cyanAccent);
  }

  // =========================================================================
  // ============= EKONOMİ & ZAMAN BÜKME MANTIĞI ================
  // =========================================================================

  void manuelZamanYavaslat() {
    if (isGameOver || isPaused || isTimeSlowed || isReviveScreenOpen) return;

    const int maliyet = 5;

    if (DataManager.totalCoins >= maliyet) {
      DataManager.totalCoins -= maliyet;
      DataManager.saveData();

      elmasYazisi.text = '💎 ${DataManager.totalCoins}';
      _showFloatingText("-$maliyet", Colors.redAccent);

      _zamanBukmeEfektiniBaslat();
    } else {
      // HUD üzerinden yönettiğimiz için buradaki diyalog artık pek açılmaz
      // ama yine de yedek olarak dursun.
      _yetersizBakiyeDiyaloguGoster(
          eksikMiktar: maliyet - DataManager.totalCoins);
    }
  }

  void _zamanBukmeEfektiniBaslat() {
    if (isTimeSlowed) return;

    isTimeSlowed = true;
    double eskiHiz = oyunHizi;

    oyunHizi = oyunHizi *
        3.0; // Yavaşlatma efekti (Değer büyüdükçe düşme aralığı uzar)

    sesCal('sfx/slow_motion.mp3');
    _showFloatingText("ZAMAN BÜKÜLDÜ! ⏳", Colors.purpleAccent);
    ekranSars(5);

    add(TimerComponent(
        period: 5.0,
        removeOnFinish: true,
        onTick: () {
          isTimeSlowed = false;
          oyunHizi = eskiHiz;
          _showFloatingText("Zaman Normale Döndü", Colors.white);
        }));
  }

  void _yetersizBakiyeDiyaloguGoster({required int eksikMiktar}) {
    // HUD sisteminde buna pek gerek kalmadı ama kodun çökmemesi için tutuyoruz.
    // Kullanıcıya toast mesajı gösterebiliriz.
    debugPrint("Yetersiz Bakiye");
  }

  // --- INPUT (KULLANICI GİRDİSİ) ---
  @override
  void onPanUpdate(DragUpdateInfo i) {
    if (isGameOver || isPaused || isReviveScreenOpen) return;
    var o = children.whereType<Kare>().where((k) => k.tur == "oyuncu");
    if (o.isEmpty) return;
    Kare k = o.first;

    if (i.delta.global.x.abs() > i.delta.global.y.abs()) {
      suruklemeBirikimiY = 0;
      suruklemeBirikimiX += i.delta.global.x;
      if (suruklemeBirikimiX.abs() >= gridSize) {
        hareketEt(k, suruklemeBirikimiX.sign.toInt());
        suruklemeBirikimiX = 0;
      }
    } else {
      if (dropLock || i.delta.global.y < 0) return;
      suruklemeBirikimiY += i.delta.global.y;
      if (suruklemeBirikimiY > 60) {
        dropLock = true;
        hizliIndir(k);
        suruklemeBirikimiY = 0;
      }
    }
  }

  @override
  void onPanEnd(DragEndInfo i) {
    dropLock = false;
    suruklemeBirikimiX = 0;
    suruklemeBirikimiY = 0;
  }

  void hizliIndir(Kare k) {
    int s = 0;
    while (!carpismaVarMi(k.position.x, k.position.y + gridSize) && s < 30) {
      k.position.y += gridSize;
      skor += 2; // Hızlı indirme bonusu
      puanEkle(
          2); // Puan ekle fonksiyonunu çağırıyoruz ki level/elmas kontrolü yapılsın
      s++;
    }
    blokKatilastir(k);
  }

  void hareketEt(Kare k, int dx) {
    double nx = k.position.x + dx * gridSize;
    int c = (size.x / gridSize).floor();
    double off = (size.x - c * gridSize) / 2;

    if (nx >= off &&
        nx < off + c * gridSize &&
        !carpismaVarMi(nx, k.position.y)) {
      k.position.x = nx;
    }
  }

  @override
  void render(Canvas c) {
    double sy = hudHeight + 20;
    double ey = size.y - safeBottomArea;
    int r = ((ey - sy) / gridSize).floor();
    int col = (size.x / gridSize).floor();
    double off = (size.x - col * gridSize) / 2;

    for (int i = 0; i < col; i++) {
      for (int j = 0; j < r; j++) {
        c.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(off + i * gridSize + 4, sy + j * gridSize + 4,
                    gridSize - 8, gridSize - 8),
                const Radius.circular(8)),
            slotPaint);
      }
    }
    super.render(c);
  }
}
