import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/screens/dashboard/cafe/menu_cafe.dart';
import 'bahan_baku_screen.dart'; // File yang kita buat sebelumnya
// import 'kelola_menu_screen.dart'; // File untuk kelola produk/menu

class CafeManagementScreen extends StatelessWidget {
  const CafeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      appBar: AppBar(
        title: const Text(
          "CAFE MANAGEMENT",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Modul Kelola",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // CARD 1: KELOLA BAHAN BAKU
            _buildMenuCard(
              context,
              title: "Kelola Bahan Baku",
              subtitle: "Stok Susu, Bubuk, Kopi (Satuan Gram/ML)",
              icon: Icons.inventory_2_rounded,
              color: const Color(0xffe21388), // Pink accent
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BahanBakuScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // CARD 2: KELOLA MENU / PRODUK
            _buildMenuCard(
              context,
              title: "Kelola Menu Cafe",
              subtitle: "Atur Harga Jual & Resep Produk",
              icon: Icons.restaurant_menu_rounded,
              color: const Color(0xff00E0C6), // Cyan accent
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuCafe()),
                );
              },
            ),

            const Spacer(),

            // Info Singkat Ringkasan
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff1c273d),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amberAccent),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Pastikan stok bahan baku dalam satuan ML/Gram untuk akurasi pemotongan stok otomatis.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xff1c273d),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 35),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
