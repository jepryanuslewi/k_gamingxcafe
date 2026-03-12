import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/shift_provider.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  @override
  void initState() {
    super.initState();
    // Cek otomatis saat masuk halaman ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null) {
        context.read<ShiftProvider>().checkActiveShift(userId).then((
          hasActive,
        ) {
          if (hasActive) {
            // Jika ada shift aktif, langsung lempar ke Home
            Navigator.pushReplacementNamed(context, '/home-pegawai');
          }
        });
      }
    });
  }

  void _selectShift(String name) async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId != null) {
      await context.read<ShiftProvider>().startShift(userId, name);
      if (mounted) Navigator.pushReplacementNamed(context, '/home-pegawai');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Pilih Shift Kerja"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            const Text(
              "Selamat Bekerja! Silahkan pilih shift Anda hari ini.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Row(
                children: [
                  _buildShiftCard(
                    title: "SHIFT 1",
                    time: "08:00 - 16:00",
                    icon: Icons.light_mode,
                    color: Colors.orange,
                    onTap: () => _selectShift("Shift 1"),
                  ),
                  const SizedBox(width: 30),
                  _buildShiftCard(
                    title: "SHIFT 2",
                    time: "16:00 - 00:00",
                    icon: Icons.dark_mode,
                    color: Colors.indigo,
                    onTap: () => _selectShift("Shift 2"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 50, color: color),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                time,
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
