import 'package:flutter/material.dart';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';
import '../core/localization.dart';
import '../data/purchase_manager.dart';

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

                          // --- PAKET 1: YEM (STARTER) ---
                          // Düz fiyat, bonus yok. Sadece diğerlerini cazip kılmak için var.
                          _buildHorizontalPack(
                            title: "STARTER PACK",
                            amount: "50",
                            priceId: "crystals_50",
                            color: Colors.blueAccent,
                            icon: Icons.layers,
                          ),
                          const SizedBox(height: 12),

                          // --- PAKET 2: ASIL SATMAK İSTEDİĞİMİZ (POPULAR) ---
                          // Üstü çizili fiyat ve bonus etiketi eklendi!
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: _buildHorizontalPack(
                              title: "POPULAR PACK",
                              amount: "250",
                              priceId: "crystals_250",
                              color: Colors.purpleAccent,
                              icon: Icons.diamond,
                              isBestValue: true,
                              bonusText: "+25% BONUS",
                              oldPrice: "₺199.99",
                            ),
                          ),
                          const SizedBox(height: 12),

                          // --- PAKET 3: BALİNA PAKETİ (LEGENDARY) ---
                          // Yüksek fiyat, devasa bonus.
                          _buildHorizontalPack(
                            title: "LEGENDARY PACK",
                            amount: "1,000",
                            priceId: "crystals_1000",
                            color: Colors.amberAccent,
                            icon: Icons.auto_awesome,
                            bonusText: "+50% MEGA",
                            oldPrice: "₺699.99",
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
              isRemoved ? Icons.verified_user_rounded : Icons.block_flipped,
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
                // DEĞİŞİKLİK: Yabancılar için daha ikonik/kısa bir mesaj
                Text(
                  isRemoved ? "Thank you!" : "Play without interruptions",
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          if (!isRemoved)
            ElevatedButton(
              onPressed: () {
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
                  Text(
                      Dil.get(
                          "izle_kazan"), // Zaten localizasyon kullanmışsın, mükemmel
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  // DEĞİŞİKLİK: İngilizce metin yerine Evrensel İkon kullanıldı
                  const Row(
                    children: [
                      Icon(Icons.card_giftcard_rounded,
                          size: 12, color: Colors.grey),
                      SizedBox(width: 4),
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
            child: const Icon(Icons.play_arrow_rounded,
                size: 24), // Sadece "Play" ikonu (Evrensel dil)
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalPack({
    required String title,
    required String amount,
    required String priceId,
    required Color color,
    required IconData icon,
    bool isBestValue = false,
    String? bonusText, // YENİ PARAMETRE
    String? oldPrice, // YENİ PARAMETRE
  }) {
    return GestureDetector(
      onTap: () {
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
                    Row(
                      children: [
                        Text(
                          amount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        // DEĞİŞİKLİK: Efsanevi Fosforlu Bonus Etiketi!
                        if (bonusText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.greenAccent
                                      .withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              bonusText,
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const Text("Crystals",
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),

            // DEĞİŞİKLİK: Fiyat ve Çizili Eski Fiyat (Decoy Effect)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (oldPrice != null)
                  Text(
                    oldPrice,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Container(
                  margin: EdgeInsets.only(top: oldPrice != null ? 2 : 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          ],
        ),
      ),
    );
  }

  String _getPrice(String productId) {
    if (productId == "crystals_50") return "₺34.99";
    if (productId == "crystals_250") return "₺149.99";
    if (productId == "crystals_1000") return "₺499.99";
    if (productId == PurchaseManager.idRemoveAds) return "₺79.99";
    return "...";
  }
}
