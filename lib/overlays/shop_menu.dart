import 'package:flutter/material.dart';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';
import '../core/localization.dart';
import '../data/purchase_manager.dart'; // Yeni PurchaseManager bağlandı

class ShopMenu extends StatefulWidget {
  final TimelessGame game;
  const ShopMenu({super.key, required this.game});

  @override
  State<ShopMenu> createState() => _ShopMenuState();
}

class _ShopMenuState extends State<ShopMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _currentCoins = 0;

  @override
  void initState() {
    super.initState();
    _currentCoins = DataManager.totalCoins;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _updateCoins() {
    setState(() {
      _currentCoins = DataManager.totalCoins;
    });
  }

  void _kapat() {
    widget.game.overlays.remove('ShopMenu');
    widget.game.overlays.remove('Shop');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. GLASSMORPHISM ARKA PLAN
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(color: Colors.black.withValues(alpha: 0.85)),
          ),

          // 2. İÇERİK
          Center(
            child: Container(
              width: 380,
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Colors.purpleAccent.withValues(alpha: 0.3),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("PREMIUM"),
                          _buildRemoveAdsCard(),
                          const SizedBox(height: 25),
                          _buildSectionTitle("FREE REWARDS"),
                          _buildWatchAdCard(),
                          const SizedBox(height: 25),
                          _buildSectionTitle("CRYSTAL SHOP"),
                          const SizedBox(height: 10),

                          // İŞTE İSTEDİĞİN DEĞİŞİKLİK: ARTIK ALT ALTA SATIR (ROW) LİSTESİ
                          _buildHorizontalPack(
                            title: "STARTER PACK",
                            amount: "50",
                            priceId:
                                "100_time_crystals", // DİKKAT: Yeni PurchaseManager ID'sine eşitlendi
                            color: Colors.blueAccent,
                            icon: Icons.layers,
                          ),
                          const SizedBox(height: 12),
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: _buildHorizontalPack(
                              title: "POPULAR PACK",
                              amount: "250",
                              priceId: "250_time_crystals",
                              color: Colors.purpleAccent,
                              icon: Icons.diamond,
                              isBestValue: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildHorizontalPack(
                            title: "LEGENDARY PACK",
                            amount: "1,000",
                            priceId: "1000_time_crystals",
                            color: Colors.amberAccent,
                            icon: Icons.auto_awesome,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // KAPAT BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: _kapat,
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white54,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.close_rounded),
                          const SizedBox(width: 8),
                          Text(Dil.get("kapat").toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 16, letterSpacing: 1.5)),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Dil.get("market"),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const Text(
              "Power up your time!",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.diamond, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                "$_currentCoins",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildRemoveAdsCard() {
    bool isRemoved = DataManager.isAdsRemoved;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRemoved
              ? [Colors.green.shade900, Colors.green.shade600]
              : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isRemoved
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.amber.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRemoved ? Icons.verified_user_rounded : Icons.diamond_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRemoved ? "VIP MEMBER" : "NO ADS PACK",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  isRemoved ? "Thank you!" : "Remove ads & Support dev",
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          if (!isRemoved)
            ElevatedButton(
              onPressed: () {
                // YENİ PurchaseManager ID'Sİ BAĞLANDI
                PurchaseManager.buyProduct(PurchaseManager.idRemoveAds);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade800,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _getPrice(PurchaseManager.idRemoveAds),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWatchAdCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.ondemand_video_rounded,
                  color: Colors.cyanAccent, size: 28),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Dil.get("izle_kazan"),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const Row(
                    children: [
                      Text("Reward: ",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Icon(Icons.diamond, size: 12, color: Colors.cyanAccent),
                      Text(" +3",
                          style: TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              widget.game.adManager.showRewardedAd(
                onReward: (amount) {
                  DataManager.totalCoins += 3;
                  DataManager.saveData();
                  _updateCoins();
                  _showSnack("+3 Kristal Eklendi! 💎", Colors.green);
                },
                onAdFailed: () {
                  _showSnack("Reklam yüklenemedi. İnternetini kontrol et.",
                      Colors.redAccent);
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("WATCH",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // İŞTE YENİ SATIR (YATAY) TASARIMI: SÜTUNLAR GİTTİ, SATIRLAR GELDİ
  // ==============================================================
  Widget _buildHorizontalPack({
    required String title,
    required String amount,
    required String priceId,
    required Color color,
    required IconData icon,
    bool isBestValue = false,
  }) {
    return GestureDetector(
      onTap: () {
        // Gerçek Satın Alma Tetiklenir
        PurchaseManager.buyProduct(priceId);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF263346),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isBestValue ? color : Colors.white10,
            width: isBestValue ? 2 : 1,
          ),
          boxShadow: isBestValue
              ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 15)]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // SOL KISIM: İkon ve Miktar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isBestValue)
                      Text(
                        "★ BEST VALUE",
                        style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w900),
                      ),
                    Text(
                      amount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text("Crystals",
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),

            // SAĞ KISIM: Fiyat Butonu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getPrice(priceId),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DÜZELTME: Fiyatları yeni ID'lere göre ayarladık ---
  String _getPrice(String productId) {
    if (productId == "100_time_crystals") return "₺34.99";
    if (productId == "250_time_crystals") return "₺149.99";
    if (productId == "1000_time_crystals") return "₺499.99";
    if (productId == PurchaseManager.idRemoveAds) return "₺79.99";
    return "...";
  }
}