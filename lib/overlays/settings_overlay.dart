import 'package:flutter/material.dart';
import '../game/timeless_game.dart';
import '../core/localization.dart'; // Dil sınıfı
import '../core/constants.dart' as Core; // Tasarım renkleri

class SettingsOverlay extends StatefulWidget {
  final TimelessGame game;
  const SettingsOverlay({super.key, required this.game});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  bool _muzikAcik = true;
  bool _sfxAcik = true;
  String _seciliDil = 'TR';

  @override
  void initState() {
    super.initState();
    // Oyunun mevcut ses durumunu çek
    _sfxAcik = widget.game.sesAcik;

    // --- HATA DÜZELTME 1 ---
    // 'mevcutDil' yerine 'currentLanguage' kullanıyoruz
    _seciliDil = Dil.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Core.Tasarim.arkaPlan,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Colors.amberAccent.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Dil.get("ayarlar").toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 30),

                // Müzik Ayarı
                _buildSwitchRow(Dil.get("muzik"), Icons.music_note, _muzikAcik,
                    (val) {
                  setState(() => _muzikAcik = val);
                  // İleride buraya müzik aç/kapa kodu gelecek
                }),
                const Divider(color: Colors.white12),

                // Ses Efektleri Ayarı
                _buildSwitchRow(Dil.get("ses"), Icons.volume_up, _sfxAcik,
                    (val) {
                  setState(() => _sfxAcik = val);
                  widget.game.sesAcik = val; // Oyuna bildir
                }),
                const Divider(color: Colors.white12),

                // Dil Seçimi
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.language, color: Colors.amberAccent),
                          const SizedBox(width: 15),
                          Text(Dil.get("dil"),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                        ],
                      ),
                      DropdownButton<String>(
                        value: _seciliDil,
                        dropdownColor: const Color(0xFF1F1F2E),
                        style: const TextStyle(color: Colors.white),
                        underline: Container(), // Çizgiyi kaldır
                        // 5 DİL DESTEĞİ BURADA
                        items: const [
                          DropdownMenuItem(
                              value: 'TR', child: Text("Türkçe 🇹🇷")),
                          DropdownMenuItem(
                              value: 'EN', child: Text("English 🇺🇸")),
                          DropdownMenuItem(
                              value: 'DE', child: Text("Deutsch 🇩🇪")),
                          DropdownMenuItem(
                              value: 'ES', child: Text("Español 🇪🇸")),
                          DropdownMenuItem(
                              value: 'FR', child: Text("Français 🇫🇷")),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _seciliDil = val;
                              // --- HATA DÜZELTME 2 ---
                              // 'sec' yerine 'switchLanguage' kullanıyoruz
                              Dil.switchLanguage(val);
                            });
                          }
                        },
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Kapat Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.game.overlays.remove('Ayarlar');
                      widget.game.overlays.add('AnaMenu');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(Dil.get("kaydet"),
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow(
      String label, IconData icon, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.amberAccent),
              const SizedBox(width: 15),
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.amberAccent,
            activeTrackColor: Colors.amberAccent.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
