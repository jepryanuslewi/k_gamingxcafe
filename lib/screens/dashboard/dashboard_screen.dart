import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/screens/dashboard/cafe/cafe_management_screen.dart';
import 'package:k_gamingxcafe/screens/dashboard/dashboard_home_screen.dart';
import 'package:k_gamingxcafe/screens/dashboard/gaming/unit_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardHomeScreen(),
    UnitsScreen(),
    CafeManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width >= 600;
    final isMobile = width < 600;

    if (isMobile) {
      return _buildMobileLayout();
    } else {
      return _buildTabletDesktopLayout(isDesktop);
    }
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      drawer: Drawer(child: _buildSidebar(isCollapsed: false)),
      body: pages[selectedIndex],
    );
  }

  Widget _buildTabletDesktopLayout(bool isDesktop) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            _buildSidebar(isCollapsed: !isDesktop),
            Expanded(child: pages[selectedIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar({required bool isCollapsed}) {
    final width = isCollapsed ? 80.0 : 220.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      color: const Color.fromARGB(255, 5, 137, 198),
      child: Column(
        children: [
          const SizedBox(height: 30),

          if (!isCollapsed)
            const Row(
              children: [
                SizedBox(width: 16),
                Icon(Icons.dashboard, color: Colors.white),
                SizedBox(width: 16),
                Text("Dashboard", style: TextStyle(color: Colors.white)),
              ],
            ),

          const SizedBox(height: 30),

          _buildMenuItem(Icons.dashboard, "Dashboard", 0, isCollapsed),
          _buildMenuItem(Icons.tv, "PS Units", 1, isCollapsed),
          _buildMenuItem(Icons.store, "CAFE MANAGEMENT", 2, isCollapsed),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    int index,
    bool isCollapsed,
  ) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: isSelected ? Colors.blueGrey : Colors.transparent,
        child: Row(
          mainAxisAlignment: isCollapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            const SizedBox(width: 16),
            Icon(icon, color: Colors.white),
            if (!isCollapsed) ...[
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(color: Colors.white)),
            ],
          ],
        ),
      ),
    );
  }
}
