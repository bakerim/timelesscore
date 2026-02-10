import 'package:flutter/material.dart';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../core/localization.dart';

class SettingsOverlay extends StatefulWidget {
  final TimelessGame game;
  const SettingsOverlay({super.key, required this.game});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  bool _musicOn = true;
  bool _sfxOn = true;

  // Desteklenen dillerin listesi
  final List<String> _languages = ['TR', 'EN', 'DE', 'ES', 'FR'];

  @override
  void initState() {
    super.initState();
    _musicOn = widget.game.muzikAcik;
    _sfxOn = widget.game.sesAcik;
  }

  void _kapat() {
    if (widget.game.overlays.isActive('Ayarlar'))
      widget.game.overlays.remove('Ayarlar');
    if (widget.game.overlays.isActive('Settings'))
      widget.game.overlays.remove('Settings');
  }

  void _dilDegistir(String langCode) {
    setState(() {
      Dil.dilDegistir(langCode); // Localization sınıfındaki metodu çağır
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Glass Background
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
                boxShadow: [
                  BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 2)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.settings_suggest_rounded,
                          color: Colors.cyanAccent, size: 28),
                      const SizedBox(width: 10),
                      Text(Dil.get("ayarlar"),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // --- DİL SEÇİMİ (5 DİL) ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        Dil.get("dil_secimi")
                            .toUpperCase(), // "DİL SEÇİMİ" / "LANGUAGE"
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),

                  // Yatay kaydırılabilir dil listesi
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

                  // --- SES AYARLARI ---
                  _buildSwitchTile(
                    label: Dil.get("muzik"),
                    icon: Icons.music_note_rounded,
                    value: _musicOn,
                    color: Colors.purpleAccent,
                    onChanged: (val) {
                      setState(() => _musicOn = val);
                      widget.game.muzikYonetimi(val);
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildSwitchTile(
                    label: Dil.get("ses"),
                    icon: Icons.volume_up_rounded,
                    value: _sfxOn,
                    color: Colors.amberAccent,
                    onChanged: (val) {
                      setState(() => _sfxOn = val);
                      widget.game.sesAcik = val;
                    },
                  ),

                  const SizedBox(height: 30),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 10),

                  // --- KAPAT ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _kapat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
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

    // Her dil için küçük bir renk/bayrak teması (Opsiyonel)
    Color langColor;
    switch (code) {
      case 'TR':
        langColor = Colors.redAccent;
        break;
      case 'EN':
        langColor = Colors.blueAccent;
        break;
      case 'DE':
        langColor = Colors.amber;
        break;
      case 'ES':
        langColor = Colors.orangeAccent;
        break;
      case 'FR':
        langColor = Colors.indigoAccent;
        break;
      default:
        langColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => _dilDegistir(code),
      child: Container(
        margin: const EdgeInsets.only(right: 10), // Butonlar arası boşluk
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected
              ? langColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
              color: isSelected ? langColor : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: langColor.withOpacity(0.4), blurRadius: 10)]
              : [],
        ),
        child: Center(
          child: Text(
            code,
            style: TextStyle(
                color: isSelected ? langColor : Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required IconData icon,
    required bool value,
    required Color color,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: value ? color.withOpacity(0.5) : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
