import 'package:flutter/material.dart';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../core/localization.dart';
import '../data/data_manager.dart';

class SettingsOverlay extends StatefulWidget {
  final TimelessGame game;
  const SettingsOverlay({super.key, required this.game});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  late bool _musicOn;
  late bool _sfxOn;
  final List<String> _languages = ['TR', 'EN', 'DE', 'ES', 'FR'];

  @override
  void initState() {
    super.initState();
    // Hafızadan oku
    _musicOn = DataManager.isMusicOn;
    _sfxOn = DataManager.isSoundOn;
  }

  void _kapat() {
    widget.game.overlays.remove('Settings');
    widget.game.overlays.remove('Ayarlar'); // Eski isimden kalan varsa temizle

    // NAVİGASYON MANTIĞI:
    // Eğer oyun PAUSED ise (duraklatılmışsa) VE GameHUD ekranda YOKSA:
    // Demek ki Ana Menüden gelmişiz veya oyun henüz başlamamış.
    if (widget.game.isPaused && !widget.game.overlays.isActive('GameHUD')) {
      widget.game.overlays.add('AnaMenu');
    }
    // Aksi takdirde (Oyun oynanıyorsa), overlay kalkınca alttaki oyun görünür.
  }

  void _dilDegistir(String langCode) {
    setState(() {
      Dil.dilDegistir(langCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.8)),
          ),
          Center(
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.95),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(Dil.get("ayarlar"),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),

                  // DİL BUTONLARI
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _languages
                          .map((lang) => _buildLangButton(lang))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // MÜZİK
                  _buildSwitchTile(
                    label: Dil.get("muzik"),
                    icon: Icons.music_note,
                    value: _musicOn,
                    color: Colors.purpleAccent,
                    onChanged: (val) {
                      setState(() => _musicOn = val);
                      widget.game.muzikYonetimi(val);
                    },
                  ),
                  const SizedBox(height: 10),

                  // SES
                  _buildSwitchTile(
                    label: Dil.get("ses"),
                    icon: Icons.volume_up,
                    value: _sfxOn,
                    color: Colors.amberAccent,
                    onChanged: (val) {
                      setState(() => _sfxOn = val);
                      widget.game.sesAcik = val;
                      DataManager.setSound(val);
                    },
                  ),

                  const SizedBox(height: 30),

                  // KAPAT BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _kapat,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent.shade700,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: Text(Dil.get("kapat"),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(String code) {
    bool isSelected = Dil.currentLanguage == code;
    return GestureDetector(
      onTap: () => _dilDegistir(code),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 45,
        height: 45,
        decoration: BoxDecoration(
            color:
                isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border:
                isSelected ? Border.all(color: Colors.white, width: 2) : null),
        child: Center(
            child: Text(code,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildSwitchTile(
      {required String label,
      required IconData icon,
      required bool value,
      required Color color,
      required Function(bool) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        trailing:
            Switch(value: value, onChanged: onChanged, activeThumbColor: color),
      ),
    );
  }
}
