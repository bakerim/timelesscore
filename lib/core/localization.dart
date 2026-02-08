import 'package:flutter/foundation.dart';

class Dil {
  // Varsayılan dil
  static String currentLanguage = 'TR';

  // Çeviri haritası
  static Map<String, String> _localizedValues = {};

  // --- BAŞLATMA METODU ---
  static Future<void> init() async {
    _loadValues('TR');
    debugPrint("Dil servisi başlatıldı: $currentLanguage");
  }

  // Dili değiştirmek için
  static void switchLanguage(String lang) {
    if (['TR', 'EN', 'DE', 'ES', 'FR'].contains(lang)) {
      currentLanguage = lang;
      _loadValues(lang);
      debugPrint("Dil değiştirildi: $lang");
    }
  }

  // Metni getiren fonksiyon
  static String get(String key) {
    if (_localizedValues.containsKey(key)) {
      return _localizedValues[key]!;
    }
    debugPrint("Eksik Çeviri Anahtarı: $key");
    return key.toUpperCase();
  }

  // --- KELİME KÜTÜPHANESİ ---
  static void _loadValues(String lang) {
    switch (lang) {
      case 'TR': // Türkçe
        _localizedValues = {
          "basla": "BAŞLAT",
          "baslat": "BAŞLAT",
          "yol_haritasi": "YOL HARİTASI",
          "ayarlar": "AYARLAR",
          "market": "MARKET",
          "rekor": "REKOR",
          "muzik": "Müzik",
          "ses": "Ses Efektleri",
          "dil": "Dil / Language",
          "kaydet": "KAYDET",
          "geri": "GERİ",
          "devam_et": "DEVAM ET",
          "puan": "Puan",
          "oyun_bitti": "OYUN BİTTİ",
          "tekrar_oyna": "TEKRAR OYNA",
          "ana_menu": "ANA MENÜ",
          "iki_kat_kazan": "2X PUAN (REKLAM)", // YENİ
          "reklam_yukleniyor": "Reklam Yükleniyor...", // YENİ
          "acemi": "Acemi",
          "cirak": "Çırak",
          "uzman": "Uzman",
          "usta": "Usta",
          "efsane": "Efsane",
          "boyut_gezgini": "Boyut Gezgini",
        };
        break;

      case 'EN': // İngilizce
        _localizedValues = {
          "basla": "PLAY",
          "baslat": "PLAY",
          "yol_haritasi": "ROADMAP",
          "ayarlar": "SETTINGS",
          "market": "SHOP",
          "rekor": "BEST",
          "muzik": "Music",
          "ses": "Sound FX",
          "dil": "Language",
          "kaydet": "SAVE",
          "geri": "BACK",
          "devam_et": "RESUME",
          "puan": "Score",
          "oyun_bitti": "GAME OVER",
          "tekrar_oyna": "PLAY AGAIN",
          "ana_menu": "MAIN MENU",
          "iki_kat_kazan": "GET 2X (ADS)", // NEW
          "reklam_yukleniyor": "Loading Ad...", // NEW
          "acemi": "Novice",
          "cirak": "Apprentice",
          "uzman": "Expert",
          "usta": "Master",
          "efsane": "Legend",
          "boyut_gezgini": "Dimension Walker",
        };
        break;

      case 'DE': // Almanca
        _localizedValues = {
          "basla": "STARTEN",
          "baslat": "STARTEN",
          "yol_haritasi": "ROADMAP",
          "ayarlar": "EINSTELLUNGEN",
          "market": "MARKT",
          "rekor": "REKORD",
          "muzik": "Musik",
          "ses": "Soundeffekte",
          "dil": "Sprache",
          "kaydet": "SPEICHERN",
          "geri": "ZURÜCK",
          "devam_et": "WEITER",
          "puan": "Punkte",
          "oyun_bitti": "SPIEL VORBEI",
          "tekrar_oyna": "NEUSTART",
          "ana_menu": "HAUPTMENÜ",
          "iki_kat_kazan": "2X PUNKTE (WERBUNG)", // NEU
          "reklam_yukleniyor": "Werbung wird geladen...", // NEU
          "acemi": "Anfänger",
          "cirak": "Lehrling",
          "uzman": "Experte",
          "usta": "Meister",
          "efsane": "Legende",
          "boyut_gezgini": "Dimensionswandler",
        };
        break;

      case 'ES': // İspanyolca
        _localizedValues = {
          "basla": "JUGAR",
          "baslat": "JUGAR",
          "yol_haritasi": "MAPA",
          "ayarlar": "AJUSTES",
          "market": "TIENDA",
          "rekor": "RÉCORD",
          "muzik": "Música",
          "ses": "Efectos",
          "dil": "Idioma",
          "kaydet": "GUARDAR",
          "geri": "VOLVER",
          "devam_et": "CONTINUAR",
          "puan": "Puntuación",
          "oyun_bitti": "JUEGO TERMINADO",
          "tekrar_oyna": "JUGAR DE NUEVO",
          "ana_menu": "MENÚ PRINCIPAL",
          "iki_kat_kazan": "GANAR 2X (PUBLICIDAD)", // NUEVO
          "reklam_yukleniyor": "Cargando publicidad...", // NUEVO
          "acemi": "Novato",
          "cirak": "Aprendiz",
          "uzman": "Experto",
          "usta": "Maestro",
          "efsane": "Leyenda",
          "boyut_gezgini": "Caminante Dimensional",
        };
        break;

      case 'FR': // Fransızca
        _localizedValues = {
          "basla": "JOUER",
          "baslat": "JOUER",
          "yol_haritasi": "PARCOURS",
          "ayarlar": "PARAMÈTRES",
          "market": "BOUTIQUE",
          "rekor": "RECORD",
          "muzik": "Musique",
          "ses": "Effets Sonores",
          "dil": "Langue",
          "kaydet": "SAUVEGARDER",
          "geri": "RETOUR",
          "devam_et": "REPRENDRE",
          "puan": "Score",
          "oyun_bitti": "FIN DE PARTIE",
          "tekrar_oyna": "REJOUER",
          "ana_menu": "MENU PRINCIPAL",
          "iki_kat_kazan": "GAGNER 2X (PUB)", // NOUVEAU
          "reklam_yukleniyor": "Chargement de la pub...", // NOUVEAU
          "acemi": "Novice",
          "cirak": "Apprenti",
          "uzman": "Expert",
          "usta": "Maître",
          "efsane": "Légende",
          "boyut_gezgini": "Voyageur Dimensionnel",
        };
        break;

      default:
        _loadValues('EN');
    }
  }
}
