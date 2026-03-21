import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/screens/main_menu_screen.dart';
import 'package:provider/provider.dart';
import '../providers/shift_provider.dart';

class ShiftScreen extends StatelessWidget {
  final int userId;

  const ShiftScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan warna background yang sama dengan JadwalScreen
      backgroundColor: const Color.fromRGBO(11, 18, 32, 1),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "PILIH SESI SHIFT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Silahkan pilih shift yang sedang bertugas saat ini",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildShiftButton(
                    context,
                    "SHIFT PAGI",
                    Icons.wb_sunny_rounded,
                    const Color(0xFFFFA726),
                    1,
                  ),
                  const SizedBox(width: 40),
                  _buildShiftButton(
                    context,
                    "SHIFT MALAM",
                    Icons.nightlight_round,
                    const Color(0xFF5C6BC0),
                    2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftButton(
    BuildContext context,
    String label,
    IconData icon,
    Color accentColor,
    int shiftNum,
  ) {
    return InkWell(
      onTap: () async {
        final shiftProvider = context.read<ShiftProvider>();
        await shiftProvider.startShift(userId, label);
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => MainMenuScreen(shiftName: label)),
            (route) => false,
          );
        }
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 280,
        height: 320,
        decoration: BoxDecoration(
          // Menggunakan warna container yang sama dengan tabel Jadwal
          color: const Color.fromRGBO(20, 28, 47, 1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lingkaran Icon
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 70, color: accentColor),
            ),
            const SizedBox(height: 30),
            Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            // Tombol "Pilih" kecil di bawah
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00E0C6), width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "PILIH SESI",
                style: TextStyle(
                  color: Color(0xFF00E0C6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
