import 'package:flutter/material.dart'; 
import 'package:k_gamingxcafe/screens/dashboard/cafe/cafe_management_screen.dart';
import 'package:k_gamingxcafe/screens/dashboard/dahboard_pegawai.dart';
import 'package:k_gamingxcafe/screens/dashboard/dashboard_home_screen.dart';
import 'package:k_gamingxcafe/screens/dashboard/gaming/unit_screen.dart';
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
    DahboardPegawai(),
    UnitsScreen(),
    CafeManagementScreen(),
  ];

  // --- FUNGSI LOGOUT DENGAN KONFIRMASI ---
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(20, 28, 47, 1),
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
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
                          const Text(
                            "Gaming x Cafe",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.1,
                            ),
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
                  icon: Icon(Icons.local_cafe_outlined),
                  label: Text("Cafe Management"),
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
                            width: 160,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.redAccent),
                                foregroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: _logout,
                              icon: const Icon(Icons.logout),
                              label: const Text("LOGOUT"),
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
