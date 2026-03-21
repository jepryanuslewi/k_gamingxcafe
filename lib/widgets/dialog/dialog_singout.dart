import 'package:flutter/material.dart';

class DialogSingout {
  static Future<void> showLogoutDialog(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // User wajib pilih tombol
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141C2F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Konfirmasi Keluar",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Apakah Anda yakin ingin mengakhiri shift dan keluar?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                onConfirm(); // Jalankan fungsi logout
              },
              child: const Text(
                "YA, KELUAR",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
