import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto', brightness: Brightness.dark),
      home: const SplashScreen(),
    )
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  String _status = "Başlatılıyor...";

  @override
  void initState() {
    super.initState();
    _baslat();
  }

  Future<void> _baslat() async {
    // 1. Reklam SDK
    setState(() { _status = "Reklam servisi hazırlanıyor..."; _progress = 0.2; });
    try {
      if (!kIsWeb) {
        await MobileAds.instance.initialize();
      }
    } catch (e) {
      print("Reklam SDK hatası: $e");
    }

    // 2. Ses Dosyaları
    setState(() { _status = "Sesler yükleniyor..."; _progress = 0.5; });
    try {
      await FlameAudio.audioCache.loadAll([
        'music/bg_music.mp3',
        'sfx/move.mp3',
        'sfx/drop.mp3',
        'sfx/clear.mp3',
        'sfx/gameover.mp3',
      ]);
    } catch (e) {
      print("Ses dosyaları yüklenirken hata: $e");
    }

    // 3. Skor Verisi
    setState(() { _status = "Veriler yükleniyor..."; _progress = 0.8; });
    await ScoreManager.yukle();

    setState(() { _status = "Hazır!"; _progress = 1.0; });
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GameScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121232),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]).createShader(bounds),
              child: const Text("TIMELESS\nCORE", textAlign: TextAlign.center, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
            ),
            const SizedBox(height: 50),
            CircularProgressIndicator(value: _progress, color: Colors.purpleAccent),
            const SizedBox(height: 20),
            Text(_status, style: const TextStyle(color: Colors.white54, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GameWidget<TimelessGame>(
          game: TimelessGame(),
          overlayBuilderMap: {
            'AnaMenu': (context, game) => AnaMenuOverlay(game: game),
            'GameOver': (context, game) => GameOverOverlay(game: game),
            'Ayarlar': (context, game) => AyarlarOverlay(game: game),
          },
          initialActiveOverlays: const ['AnaMenu'],
        ),
      );
  }
}

// --- SKOR YÖNETİCİSİ ---
class ScoreManager {
  static int highScore = 0;
  static Future<void> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('high_score') ?? 0;
  }
  static Future<void> kaydet(int score) async {
    if (score > highScore) {
      highScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('high_score', highScore);
    }
  }
}

class Tasarim {
  static const Color arkaPlan = Color(0xFF121232);
  static const Color bosSlot = Color(0xFF1E1E40);
  static const List<Color> renkler = [
    Color(0xFF3F51B5), Color(0xFF00BCD4), Color(0xFF9C27B0),
    Color(0xFFFFEB3B), Color(0xFFFF5722), Color(0xFFE91E63),
  ];
  static const Color playButton = Color(0xFF2962FF);
  static const Color secondaryButton = Color(0xFF303050);
  static Color rastgeleRenk() => renkler[Random().nextInt(renkler.length)];
}

// --- OYUN MOTORU ---
class TimelessGame extends FlameGame with PanDetector, TapDetector {
  late Kare oyuncu;
  late TextComponent skorYazisi;
  late TextComponent yuksekSkorYazisi;
  late TextComponent comboYazisi; 
  
  final double gridSize = 50.0;
  final double hudHeight = 160.0; 
  double sayac = 0;
  double oyunHizi = 0.5;
  int skor = 0;
  int comboSayaci = 0;
  bool isGameOver = false;
  bool isPaused = true;
  bool sesAcik = true;

  // ADMOB
  RewardedAd? _rewardedAd;
  bool reklamKullanildi = false; 
  bool reklamHazir = false;
  final String reklamBirimID = 'ca-app-pub-3940256099942544/5224354917'; // Test ID

  double suruklemeBirikimiX = 0;
  double suruklemeBirikimiY = 0;
  bool dropLock = false;

  final Paint slotPaint = Paint()..color = Tasarim.bosSlot..style = PaintingStyle.fill;
  final Random _rng = Random();

  @override
  Color backgroundColor() => Tasarim.arkaPlan;

  @override
  Future<void> onLoad() async {
    // ScoreManager.yukle(); // Splash ekranında zaten yüklendi
    reklamYukle();
    
    // MÜZİK BAŞLAT
    if (sesAcik) {
      try {
        if(!kIsWeb) {
             FlameAudio.bgm.play('music/bg_music.mp3', volume: 0.3);
        } else {
            // Web için kullanıcı etkileşimi gerekebilir, şimdilik deneyelim
             FlameAudio.bgm.play('music/bg_music.mp3', volume: 0.3);
        }
       
      } catch(e) { print("Müzik bulunamadı veya hata: $e"); }
    }

    add(RectangleComponent(
      position: Vector2(0, 0), size: Vector2(size.x, hudHeight),
      paint: Paint()..color = Tasarim.arkaPlan.withOpacity(0.95), priority: 5
    ));

    skorYazisi = TextComponent(
      text: '0', textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.w900)),
      position: Vector2(size.x / 2, 60), anchor: Anchor.topCenter, priority: 10,
    );
    add(skorYazisi);

    yuksekSkorYazisi = TextComponent(
      text: 'Best: ${ScoreManager.highScore}',
      textRenderer: TextPaint(style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
      position: Vector2(size.x / 2, 125), anchor: Anchor.topCenter, priority: 10,
    );
    add(yuksekSkorYazisi);

    comboYazisi = TextComponent(
      text: '', textRenderer: TextPaint(style: TextStyle(color: Tasarim.renkler[3], fontSize: 30, fontWeight: FontWeight.bold)),
      position: Vector2(size.x / 2, hudHeight + 50), anchor: Anchor.center, priority: 20,
    );
    add(comboYazisi);
  }

  void reklamYukle() {
    if (kIsWeb) return; // Web'de reklam desteği sınırlı olabilir veya farklı yapılandırma gerekebilir
    
    RewardedAd.load(
      adUnitId: reklamBirimID,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          reklamHazir = true;
        },
        onAdFailedToLoad: (error) {
          print('Reklam yüklenemedi: $error');
          _rewardedAd = null;
          reklamHazir = false;
        },
      ),
    );
  }

  void reklamIzleVeDevamEt() {
    if (kIsWeb) {
        // Web için geçici çözüm: direkt devam et
        devamEt();
        return;
    }

    if (_rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (adWithoutView, reward) {
          devamEt();
        });
    } else {
        print("Reklam hazır değil");
    }
  }

  void devamEt() {
      altSatirlariTemizle(4);
      overlays.remove('GameOver');
      isGameOver = false; isPaused = false;
      reklamKullanildi = true;
      reklamHazir = false;
      reklamYukle();
  }

  void altSatirlariTemizle(int satirSayisi) {
      if (sesAcik) try { FlameAudio.play('sfx/clear.mp3'); } catch(e){} 
      
      double gridStartY = hudHeight + 20;
      double gridAvailableHeight = size.y - gridStartY - 20;
      int rows = (gridAvailableHeight / gridSize).floor();
      double temizlenecekLimitY = gridStartY + (rows - satirSayisi) * gridSize;

      children.whereType<Kare>().where((k) => k.tur == "duvar").forEach((k) {
         if (k.position.y >= temizlenecekLimitY) {
           patlamaEfekti(k.position, k.paint.color);
           k.removeFromParent();
         }
      });
  }

  void oyunuBaslat() { 
      overlays.remove('AnaMenu'); 
      isPaused = false; 
      
      // Web'de ses için kullanıcı etkileşimi sonrası tekrar başlatmayı dene
      if (sesAcik && !FlameAudio.bgm.isPlaying) {
          try { FlameAudio.bgm.play('music/bg_music.mp3', volume: 0.3); } catch(e){}
      }
      
      oyunuSifirla(); 
  }
  
  void anaMenuyeDon() {
    overlays.remove('GameOver');
    overlays.add('AnaMenu');
    // Oyun alanındaki kareleri temizle
    children.whereType<Kare>().where((k) => k.tur != "hud").forEach((k) => k.removeFromParent());
    isPaused = true;
    isGameOver = false;
  }
  
  void oyunuBitir() { 
    isGameOver = true; isPaused = true; 
    if (sesAcik) try { FlameAudio.play('sfx/gameover.mp3'); } catch(e){}
    
    ScoreManager.kaydet(skor);
    ScoreManager.yukle().then((_) { yuksekSkorYazisi.text = 'Best: ${ScoreManager.highScore}'; });
    overlays.add('GameOver'); 
  }

  void oyunuSifirla() {
    overlays.remove('GameOver');
    children.whereType<Kare>().where((k) => k.tur != "hud").forEach((k) => k.removeFromParent());
    skor = 0; comboSayaci = 0; comboYazisi.text = ''; oyunHizi = 0.5;
    skorYazisi.text = '$skor';
    yuksekSkorYazisi.text = 'Best: ${ScoreManager.highScore}';
    isGameOver = false; isPaused = false; dropLock = false; reklamKullanildi = false;
    spawnOyuncu();
  }

  void spawnOyuncu() {
    if (isGameOver || isPaused) return;
    double gridStartY = hudHeight + 20;
    int cols = (size.x / gridSize).floor();
    double gridOffsetX = (size.x - (cols * gridSize)) / 2;
    double baslangicX = gridOffsetX + (cols / 2).floor() * gridSize;
    double baslangicY = gridStartY; 

    if (carpismaVarMi(baslangicX, baslangicY)) { oyunuBitir(); return; }

    oyuncu = Kare(gridSize, renk: Tasarim.rastgeleRenk(), tur: "oyuncu");
    oyuncu.position = Vector2(baslangicX, baslangicY);
    add(oyuncu);
    suruklemeBirikimiX = 0; suruklemeBirikimiY = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver || isPaused) return;
    if (children.whereType<Kare>().where((k) => k.tur == "oyuncu").isEmpty) return;
    sayac += dt;
    if (sayac > oyunHizi) { sayac = 0; yercekimiAdimi(); }
  }

  void yercekimiAdimi() {
     var oyuncular = children.whereType<Kare>().where((k) => k.tur == "oyuncu");
     if (oyuncular.isEmpty) return;
     Kare aktifKare = oyuncular.first;
      if (carpismaVarMi(aktifKare.position.x, aktifKare.position.y + gridSize)) { 
        blokKatilastir(aktifKare); 
      } else { 
        aktifKare.position.y += gridSize; 
      }
  }

  bool carpismaVarMi(double x, double y) {
    double gridStartY = hudHeight + 20;
    double gridAvailableHeight = size.y - gridStartY - 20;
    int rows = (gridAvailableHeight / gridSize).floor();
    double gridEndY = gridStartY + rows * gridSize;
    if (y >= gridEndY) return true;
    for (final component in children) {
      if (component is Kare && component.tur == "duvar" && !component.isRemoving) {
        if ((component.position.x - x).abs() < 5 && (component.position.y - y).abs() < 5) return true;
      }
    }
    return false;
  }

  void blokKatilastir(Kare k) {
    if (sesAcik) try { FlameAudio.play('sfx/drop.mp3'); } catch(e){} 
    k.tur = "duvar";
    bool satirSilindi = satirTemizle();
    if (!satirSilindi) { comboSayaci = 0; comboYazisi.text = ''; }
    spawnOyuncu();
  }

  void patlamaEfekti(Vector2 position, Color color) {
    add(ParticleSystemComponent(
      particle: Particle.generate(count: 20, lifespan: 0.8, generator: (i) => AcceleratedParticle(
        acceleration: Vector2(0, 400),
        speed: Vector2(_rng.nextDouble() * 300 - 150, _rng.nextDouble() * 300 - 150),
        position: position + Vector2(gridSize/2, gridSize/2),
        child: CircleParticle(radius: 4, paint: Paint()..color = color.withOpacity(0.8))
      ))
    ));
  }

  bool satirTemizle() {
    double gridStartY = hudHeight + 20;
    double gridAvailableHeight = size.y - gridStartY - 20;
    int rows = (gridAvailableHeight / gridSize).floor();
    int cols = (size.x / gridSize).floor();
    bool temizlendi = false;

    for (int j = rows - 1; j >= 0; j--) {
      double checkY = gridStartY + j * gridSize;
      List<Kare> satirdakiBloklar = children.whereType<Kare>().where((k) => k.tur == "duvar" && !k.isRemoving && (k.position.y - checkY).abs() < 5).toList();

      if (satirdakiBloklar.length >= cols) {
        if (sesAcik) try { FlameAudio.play('sfx/clear.mp3'); } catch(e){} 
        for (var blok in satirdakiBloklar) { patlamaEfekti(blok.position, blok.paint.color); blok.removeFromParent(); }
        temizlendi = true; comboSayaci++; int puan = 100 * comboSayaci; skor += puan;
        oyunHizi = max(0.1, oyunHizi - 0.02);
        skorYazisi.text = '$skor';
        if (comboSayaci > 1) { comboYazisi.text = '${comboSayaci}x COMBO'; }
        for (final component in children) {
          if (component is Kare && component.tur == "duvar" && !component.isRemoving && component.position.y < checkY) {
            component.position.y += gridSize;
          }
        }
        return true; 
      }
    }
    return temizlendi;
  }

  @override
  void render(Canvas canvas) {
    double gridStartY = hudHeight + 20; 
    double gridAvailableHeight = size.y - gridStartY - 20; 
    int rows = (gridAvailableHeight / gridSize).floor();
    int cols = (size.x / gridSize).floor();
    double gridOffsetX = (size.x - (cols * gridSize)) / 2;

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        double x = gridOffsetX + i * gridSize;
        double y = gridStartY + j * gridSize;
        RRect rrect = RRect.fromRectAndRadius(Rect.fromLTWH(x + 4, y + 4, gridSize - 8, gridSize - 8), const Radius.circular(12.0));
        canvas.drawRRect(rrect, slotPaint);
      }
    }
    super.render(canvas);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isGameOver || isPaused) return;
    var aktifOyuncular = children.whereType<Kare>().where((k) => k.tur == "oyuncu" && !k.isRemoving);
    if (aktifOyuncular.isEmpty) return;
    Kare aktifKare = aktifOyuncular.first;
    double dx = info.delta.global.x; double dy = info.delta.global.y;

    if (dx.abs() > dy.abs()) {
      suruklemeBirikimiY = 0; suruklemeBirikimiX += dx;
      if (suruklemeBirikimiX >= gridSize) { 
        hareketEt(aktifKare, 1, 0); suruklemeBirikimiX = 0; 
      } else if (suruklemeBirikimiX <= -gridSize) { 
        hareketEt(aktifKare, -1, 0); suruklemeBirikimiX = 0; 
      }
    } else {
      if (dropLock) return;
      if (dy < 0) { suruklemeBirikimiY = 0; return; } 
      suruklemeBirikimiY += dy;
      if (suruklemeBirikimiY > 60) { dropLock = true; hizliIndir(aktifKare); suruklemeBirikimiY = 0; }
    }
  }

  @override
  void onPanEnd(DragEndInfo info) { dropLock = false; suruklemeBirikimiY = 0; suruklemeBirikimiX = 0; }

  void hizliIndir(Kare k) {
    while (!carpismaVarMi(k.position.x, k.position.y + gridSize)) {
      k.position.y += gridSize; skor += 2; skorYazisi.text = '$skor';
    }
    blokKatilastir(k);
  }

  void hareketEt(Kare k, int dx, int dy) {
    double yeniX = k.position.x + (dx * gridSize);
    int cols = (size.x / gridSize).floor();
    double gridOffsetX = (size.x - (cols * gridSize)) / 2;
    double gridEndX = gridOffsetX + cols * gridSize;
    if (yeniX >= gridOffsetX && yeniX < gridEndX && !carpismaVarMi(yeniX, k.position.y)) {
      if (sesAcik) try { FlameAudio.play('sfx/move.mp3'); } catch(e){} 
      k.position.x = yeniX;
    }
  }
}

// --- GÖRSEL BİLEŞENLER ---
class Kare extends PositionComponent {
  String tur;
  Paint paint;
  Paint glowPaint; 
  Kare(double boy, {this.tur = "oyuncu", required Color renk}) :
    paint = Paint()..color = renk..style = PaintingStyle.fill,
    glowPaint = Paint()..color = renk.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12), 
    super(size: Vector2(boy, boy), anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    double padding = 3.0; 
    Rect rect = Rect.fromLTWH(padding, padding, size.x - (padding*2), size.y - (padding*2));
    RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10.0)); 
    if (tur != "hud") canvas.drawRRect(rrect.inflate(3), glowPaint);
    canvas.drawRRect(rrect, paint);
  }
}

class AnaMenuOverlay extends StatelessWidget {
  final TimelessGame game;
  const AnaMenuOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Tasarim.arkaPlan, Color(0xFF0A0A20)])),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // LOGO
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]).createShader(bounds),
              child: const Text("TIMELESS\nCORE", textAlign: TextAlign.center, style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
            ),
            const SizedBox(height: 80),
            ElevatedButton.icon(onPressed: () => game.oyunuBaslat(), style: ElevatedButton.styleFrom(backgroundColor: Tasarim.playButton, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20)), icon: const Icon(Icons.play_arrow, size: 30), label: const Text("OYNA", style: TextStyle(fontSize: 24))),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () { game.overlays.remove('AnaMenu'); game.overlays.add('Ayarlar'); }, child: const Text("AYARLAR")),
      ])),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  final TimelessGame game;
  const GameOverOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("OYUN BİTTİ", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            Text("Skor: ${game.skor}", style: const TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 10),
            Text("Rekor: ${ScoreManager.highScore}", style: const TextStyle(color: Colors.amber, fontSize: 18)),
            const SizedBox(height: 30),
            
            // REKLAM BUTONU
            if (!game.reklamKullanildi && (game.reklamHazir || kIsWeb))
            ElevatedButton.icon(
              onPressed: () => game.reklamIzleVeDevamEt(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              icon: const Icon(Icons.video_library),
              label: const Text("İZLE VE DEVAM ET"),
            ),
            
            if (!game.reklamKullanildi && !game.reklamHazir && !kIsWeb)
            const Padding(padding: EdgeInsets.all(8.0), child: Text("Reklam Yükleniyor...", style: TextStyle(color: Colors.white54))),

            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(icon: const Icon(Icons.home, size: 40, color: Colors.white), onPressed: () => game.anaMenuyeDon()),
                const SizedBox(width: 30),
                IconButton(icon: const Icon(Icons.refresh, size: 50, color: Colors.blue), onPressed: () => game.oyunuSifirla()),
            ])
      ])),
    );
  }
}

class AyarlarOverlay extends StatefulWidget {
  final TimelessGame game;
  const AyarlarOverlay({super.key, required this.game});
  @override
  State<AyarlarOverlay> createState() => _AyarlarOverlayState();
}

class _AyarlarOverlayState extends State<AyarlarOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Tasarim.arkaPlan, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
       const Text("AYARLAR", style: TextStyle(color: Colors.white, fontSize: 30)),
       const SizedBox(height: 40),
       SwitchListTile(
         title: const Text("Ses Efektleri", style: TextStyle(color: Colors.white)), 
         value: widget.game.sesAcik, 
         onChanged: (val) {
           setState(() { widget.game.sesAcik = val; });
           if (!val) { 
             FlameAudio.bgm.stop(); 
           } else { 
             try { FlameAudio.bgm.play('music/bg_music.mp3'); } catch(e){}
           }
       }),
       const SizedBox(height: 40),
       ElevatedButton(onPressed: () { widget.game.overlays.remove('Ayarlar'); widget.game.overlays.add('AnaMenu'); }, child: const Text("GERİ DÖN")),
    ])));
  }
}