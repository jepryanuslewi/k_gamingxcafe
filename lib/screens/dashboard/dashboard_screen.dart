import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/screens/dashboard/cafe/cafe_management_screen.dart';
import 'package:k_gamingxcafe/screens/dashboard/dahboard_pegawai.dart';
import 'package:k_gamingxcafe/screens/dashboard/dashboard_home_screen.dart';
import 'package:k_gamingxcafe/screens/dashboard/gaming/unit_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isExpanded =
      true; // Default expanded untuk tablet agar logo terlihat jelas

  final List<Widget> _pages = const [
    DashboardHomeScreen(),
    DahboardPegawai(),
    UnitsScreen(),
    CafeManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Tema Cafe
    const Color primaryBg = Color.fromRGBO(20, 28, 47, 1); // Biru Gelap
    const Color accentColor = Color(0xFF00E0C6); // Teal/Cyan khas Gaming
    const Color secondaryBg = Color.fromRGBO(10, 15, 28, 1); // Hitam Kebiruan

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

              // --- BAGIAN LOGO & HEADER ---
              leading: Column(
                children: [
                  const SizedBox(height: 10),
                  // Container untuk Logo
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _isExpanded ? 16 : 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Tempat Simpan Logo
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

                  // Tombol Toggle Sidebar
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.keyboard_arrow_left : Icons.menu,
                      color: Colors.white70,
                    ),
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                  const SizedBox(height: 10),
                ],
              ),

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
            ),

            // Area Konten
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: secondaryBg,
                  // Memberikan sedikit efek shadow agar sidebar terlihat terpisah
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(-5, 0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  // Membulatkan sudut konten agar terlihat modern di tablet
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
