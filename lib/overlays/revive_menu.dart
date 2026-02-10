import 'dart:async';
import 'package:flutter/material.dart';
import '../game/timeless_game.dart'; // AdManager buradan erişilecek
import '../core/localization.dart';

class ReviveMenu extends StatefulWidget {
  final TimelessGame game;
  const ReviveMenu({super.key, required this.game});

  @override
  State<ReviveMenu> createState() => _ReviveMenuState();
}

class _ReviveMenuState extends State<ReviveMenu>
    with SingleTickerProviderStateMixin {
  int _counter = 5;
  late Timer _timer;
  late AnimationController _controller;

  // Reklam durumu artık AdManager'dan sorulacak, burada tutmaya gerek yok
  bool _isAdReady = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);

    // 1. Oyuna "Reklam Yüklemeyi Dene" emri veriyoruz (Eğer zaten yüklüyse sorun yok)
    // AdManager kendi içinde kontrol eder.
    widget.game.adManager.loadRewardedAd();

    // 2. Zamanlayıcı hem geri sayımı yapar hem de reklamın durumunu kontrol eder
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Her saniye AdManager'a sor: Reklam hazır mı?
      bool ready = widget.game.adManager.isRewardedAdReady;

      setState(() {
        _isAdReady = ready;
        if (_counter > 0) {
          _counter--;
        } else {
          // Süre doldu, reklam izlemediyse bitir
          timer.cancel();
          widget.game.vazgecVeBitir();
        }
      });
    });
  }

  // --- REKLAM GÖSTERME FONKSİYONU (DÜZELTİLDİ) ---
  void _showReviveAd() {
    // Timer'ı durdur ki arkada süre akmasın
    _timer.cancel();

    // AdManager üzerindeki fonksiyonu DOĞRU parametrelerle çağırıyoruz
    widget.game.adManager.showRewardedAd(
        // 1. Parametre: Ödül Kazanıldığında
        onReward: (amount) {
      debugPrint("Ödül kazanıldı: $amount");
      widget.game.devamEtIslemi();
    },
        // 2. Parametre: Hata Olduğunda
        onAdFailed: () {
      // Reklam açılamadıysa kullanıcıyı mağdur etme, oyunu bitir veya uyarı ver
      // Biz burada garantici olup oyunu bitiriyoruz (veya yeniden deneteibilirsin)
      debugPrint("Reklam gösterilemedi.");
      widget.game.vazgecVeBitir();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Dil.get("ikinci_sans"),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  shadows: [Shadow(color: Colors.greenAccent, blurRadius: 10)]),
            ),
            const SizedBox(height: 10),
            Text(
              Dil.get("devam_et_aciklama"),
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // GERİ SAYIM HALKASI
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _counter / 5,
                    color: Colors.cyanAccent,
                    backgroundColor: Colors.white10,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  "$_counter",
                  style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 60,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- AKILLI REKLAM İZLE BUTONU ---
            _buildReviveButton(),

            const SizedBox(height: 25),

            // VAZGEÇ BUTONU
            TextButton(
              onPressed: () {
                widget.game.vazgecVeBitir();
              },
              child: Text(Dil.get("vazgec"),
                  style: const TextStyle(color: Colors.white38, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviveButton() {
    // Buton metni ve durumu
    String buttonText = Dil.get("reklam_yukleniyor");
    Color buttonColor = Colors.grey.shade800;
    IconData buttonIcon = Icons.hourglass_empty_rounded;
    VoidCallback? onPressedAction; // Başlangıçta null (tıklanamaz)

    if (_isAdReady) {
      // Reklam Hazırsa
      buttonText = Dil.get("izle_devam_et");
      buttonColor = Colors.greenAccent.shade700;
      buttonIcon = Icons.play_circle_fill_rounded;
      onPressedAction = () => _showReviveAd();
    } else {
      // Reklam Henüz Hazır Değilse (Yükleniyor)
      buttonText = Dil.get("reklam_yukleniyor");
    }

    Widget buttonChild = ElevatedButton.icon(
      onPressed: onPressedAction,
      icon: Icon(buttonIcon, size: 32),
      label: Text(buttonText,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade900,
        disabledForegroundColor: Colors.white38,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
      ),
    );

    // Sadece reklam hazırsa parlama efekti ekle
    if (_isAdReady) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.greenAccent.withOpacity(0.6 * _controller.value),
                    blurRadius: 20 + (10 * _controller.value),
                    spreadRadius: 2,
                  )
                ]),
            child: child,
          );
        },
        child: buttonChild,
      );
    }

    return buttonChild;
  }
}
