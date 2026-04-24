import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/screens/dashboard/cafe/bahan_baku_screen.dart';
import 'package:k_gamingxcafe/screens/dashboard/cafe/menu_cafe_screen.dart';
import 'package:k_gamingxcafe/screens/dashboard/dashboard_home_screen.dart';
import 'package:k_gamingxcafe/screens/dashboard/dashboard_pegawai_screen.dart';
import 'package:k_gamingxcafe/screens/dashboard/gaming/add_paket_event_screen.dart';
import 'package:k_gamingxcafe/screens/dashboard/gaming/add_ps_unit_screen.dart';
import 'package:k_gamingxcafe/screens/dashboard/laporan/dashboard_laporan_screen.dart';
import 'package:k_gamingxcafe/screens/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isExpanded = true;

  final List<Widget> _pages = const [
    DashboardHomeScreen(),
    DashboardPegawaiScreen(),
    AddPsUnitScreen(),
    AddPaketEventScreen(),
    BahanBakuScreen(),
    MenuCafeScreen(),
    DashboardLaporanScreen(shiftName: 'admin'),
  ];

  // --- FUNGSI LOGOUT DENGAN KONFIRMASI ---
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(20, 28, 47, 1),
        title: const Text("SIGN OUT", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Apakah Anda yakin ingin keluar?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // Hapus semua route dan kembali ke Login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              "Keluar",
              style: TextStyle(color: Color(0xFF00E0C6)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBg = Color.fromRGBO(20, 28, 47, 1);
    const Color accentColor = Color(0xFF00E0C6);
    const Color secondaryBg = Color.fromRGBO(10, 15, 28, 1);

    return Scaffold(
      backgroundColor: secondaryBg,
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              extended: _isExpanded,
              backgroundColor: primaryBg,
              unselectedIconTheme: const IconThemeData(
                color: Colors.white54,
                size: 24,
              ),
              selectedIconTheme: const IconThemeData(
                color: accentColor,
                size: 28,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              indicatorColor: accentColor.withOpacity(0.1),

              // --- HEADER ---
              leading: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _isExpanded ? 16 : 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset("assets/images/bgLoginScreen.png"),
                        ),
                        if (_isExpanded) ...[
                          const SizedBox(width: 12),
                          Row(
                            children: const [
                              Text(
                                "GAMING",
                                style: TextStyle(
                                  color: Color.fromRGBO(226, 19, 136, 100),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins",
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                "X",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: "Poppins",
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                "CAFE",
                                style: TextStyle(
                                  color: Color.fromRGBO(0, 224, 198, 100),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Colors.white10,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.keyboard_arrow_left : Icons.menu,
                      color: Colors.white70,
                    ),
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                ],
              ),

              // --- MENU UTAMA ---
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: Text("Dashboard"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.badge_outlined),
                  label: Text("Pegawai"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.videogame_asset_outlined),
                  label: Text("PS Units"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.event_note),
                  label: Text("Paket Promo"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_rounded),
                  label: Text("Kelola Bahan Baku"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.restaurant_menu_rounded),
                  label: Text("Kelola Menu Cafe"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_rounded),
                  label: Text("Kelola Laporan"),
                ),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },

              // --- TOMBOL LOGOUT (TRAILING) ---
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: _isExpanded
                        ? SizedBox(
                            width: 200,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),

                                foregroundColor: Colors.white,
                                backgroundColor: Color.fromRGBO(
                                  226,
                                  19,
                                  136,
                                  100,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: _logout,
                              icon: const Icon(Icons.logout),
                              label: const Text("SIGN OUT"),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.redAccent,
                            ),
                            onPressed: _logout,
                          ),
                  ),
                ),
              ),
            ),

            // AREA KONTEN
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: secondaryBg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(-5, 0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                  child: _pages[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
