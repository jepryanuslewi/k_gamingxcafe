import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/cafe/cafe_provider.dart';
import 'package:k_gamingxcafe/providers/shift_provider.dart';
import 'package:k_gamingxcafe/widgets/dialog/add_product_dialog.dart';
import 'package:provider/provider.dart';

class UpdateStockDialog extends StatefulWidget {
  final List<Map<String, dynamic>> existingProducts;

  const UpdateStockDialog({super.key, required this.existingProducts});

  @override
  State<UpdateStockDialog> createState() => _UpdateStockDialogState();
}

class _UpdateStockDialogState extends State<UpdateStockDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductId;
  String? _selectedProductName;
  String? _selectedCategory;
  final TextEditingController _qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF141C2F),
      title: const Text(
        "Input Stok Bahan",
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pilih Barang yang sudah ada di database
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF141C2F),
              style: const TextStyle(color: Colors.white),
              decoration: _buildDecoration("Pilih Barang", Icons.inventory_2),
              items: widget.existingProducts.map((p) {
                return DropdownMenuItem(
                  value: "${p['id']}|${p['name']}|${p['category']}",
                  child: Text(p['name']),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  var parts = val.split('|');
                  _selectedProductId = parts[0];
                  _selectedProductName = parts[1];
                  _selectedCategory = parts[2];
                }
              },
              validator: (v) => v == null ? "Pilih barang" : null,
            ),
            const SizedBox(height: 15),

            // Input Jumlah
            TextFormField(
              controller: _qtyController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _buildDecoration("Jumlah Tambah Stok", Icons.add_box),
              validator: (v) => v!.isEmpty ? "Isi jumlah" : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("BATAL"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E0C6),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'product_id': int.parse(_selectedProductId!),
                'name': _selectedProductName,
                'category': _selectedCategory,
                'qty': int.parse(_qtyController.text),
              });
            }
          },
          child: const Text(
            "UPDATE STOK",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFF00E0C6)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00E0C6)),
      ),
    );
  }
}

void _handleSaveStock(BuildContext context) async {
  // 1. Ambil data produk yang sudah ada dari Provider
  final cafeProvider = context.read<CafeProvider>();

  // 2. Munculkan UpdateStockDialog (BUKAN AddProductDialog)
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) =>
        UpdateStockDialog(existingProducts: cafeProvider.products),
  );

  if (result != null) {
    final auth = context.read<AuthProvider>();
    final shift = context.read<ShiftProvider>();

    // 3. Gabungkan data untuk LOG dan UPDATE
    final Map<String, dynamic> completeLog = {
      'product_id': result['product_id'], // Untuk update stok di tabel products
      'name': result['name'],
      'category': result['category'],
      'qty': result['qty'],
      'username': auth.user?.username ?? "Unknown",
      'shift': shift.activeShiftName ?? "No Shift",
    };

    // 4. Simpan ke Database melalui Provider
    await cafeProvider.addStockLog(completeLog);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Stok bahan berhasil diperbarui!")),
      );
    }
  }
}
