import 'package:flutter/material.dart';
import 'dart:ui';
import '../game/timeless_game.dart';
import '../data/data_manager.dart';
import '../data/purchase_manager.dart';
import '../core/localization.dart';
// import '../game/ad_manager.dart';

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

    // "En Popüler" kartı için nefes alma animasyonu
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
            child: Container(color: Colors.black.withOpacity(0.85)),
          ),

          // 2. İÇERİK
          Center(
            child: Container(
              width: 380,
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Colors.purpleAccent.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.15),
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
                          // GÜNCELLENEN REKLAM KARTI BURADA
                          _buildWatchAdCard(),

                          const SizedBox(height: 25),

                          _buildSectionTitle("CRYSTAL SHOP"),
                          const SizedBox(height: 10),
                          _buildCoinPacksGrid(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        widget.game.overlays.remove('Shop');
                      },
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
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
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
          color: Colors.white.withOpacity(0.4),
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
                ? Colors.green.withOpacity(0.3)
                : Colors.amber.withOpacity(0.3),
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
              color: Colors.white.withOpacity(0.2),
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
                      color: Colors.white.withOpacity(0.8), fontSize: 12),
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

  // --- REKLAM İZLEME ALANI (GÜNCELLENDİ: +3 KRİSTAL) ---
  Widget _buildWatchAdCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
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
                      // BURASI GÜNCELLENDİ: +3
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
              // --- AD MANAGER ÇAĞRISI ---
              widget.game.adManager.showRewardedAd(
                onReward: (amount) {
                  // MANTIK: Kullanıcı önerisine göre 3 Kristal veriyoruz.
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

  // --- PAKETLER GRID (DEĞERLİ PAKETLER) ---
  Widget _buildCoinPacksGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPackCard(
                title: "STARTER",
                amount: "1,000", // Artık 1000 kristal çok değerli
                priceId: PurchaseManager.idCoinPack1,
                color: Colors.blueAccent,
                icon: Icons.layers,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: _buildPackCard(
                  title: "POPULAR",
                  amount: "5,000",
                  priceId: "timeless_coin_pack_pro",
                  color: Colors.purpleAccent,
                  icon: Icons.diamond,
                  isBestValue: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: _buildPackCard(
            title: "LEGENDARY",
            amount: "15,000",
            priceId: "timeless_coin_pack_mega",
            color: Colors.amberAccent,
            icon: Icons.auto_awesome,
            isWide: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPackCard({
    required String title,
    required String amount,
    required String priceId,
    required Color color,
    required IconData icon,
    bool isBestValue = false,
    bool isWide = false,
  }) {
    return GestureDetector(
      onTap: () {
        PurchaseManager.buyProduct(priceId);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF263346),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isBestValue ? color : Colors.white10,
                width: isBestValue ? 2 : 1,
              ),
              boxShadow: isBestValue
                  ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15)]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: isWide ? 40 : 32),
                const SizedBox(height: 10),
                Text(
                  amount,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: isWide ? 24 : 20,
                      fontWeight: FontWeight.w900),
                ),
                Text("Crystals", style: TextStyle(color: color, fontSize: 10)),
                const SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 30 : 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getPrice(priceId),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isBestValue)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "BEST VALUE",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getPrice(String productId) {
    // Gerçekçi Fiyatlandırma (Kur ve Kristal değerine göre)
    if (productId == PurchaseManager.idCoinPack1) {
      return "₺39.99"; // 1000 Kristal
    }
    if (productId == "timeless_coin_pack_pro") return "₺149.99"; // 5000 Kristal
    if (productId == "timeless_coin_pack_mega") {
      return "₺399.99"; // 15000 Kristal
    }
    if (productId == PurchaseManager.idRemoveAds) return "₺79.99";
    return "...";
  }
}
