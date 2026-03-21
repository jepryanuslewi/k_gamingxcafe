import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller disesuaikan dengan kolom di tabel 'products'
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  
  // Kategori sesuai komentar di DatabaseService Anda
  String? _selectedCategory;
  final List<String> _categories = ['Makanan', 'Minuman'];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF141C2F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "STOCK BARANG",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input Nama
              _buildTextField(
                controller: _nameController,
                label: "Nama Produk",
                icon: Icons.shopping_cart,
              ),
              const SizedBox(height: 15),

              // Input Harga (Integer)
              _buildTextField(
                controller: _priceController,
                label: "Harga Jual",
                icon: Icons.payments,
                isNumber: true,
              ),
              const SizedBox(height: 15),

              // Input Stok (Integer)
              _buildTextField(
                controller: _stockController,
                label: "Jumlah Stok",
                icon: Icons.inventory_2,
                isNumber: true,
              ),
              const SizedBox(height: 15),

              // Dropdown Kategori
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF141C2F),
                style: const TextStyle(color: Colors.white),
                initialValue: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                decoration: _buildInputDecoration("Kategori", Icons.category),
                validator: (v) => v == null ? "Pilih kategori" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E0C6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Mengembalikan data Map yang siap dimasukkan ke db.insert
              Navigator.pop(context, {
                'name': _nameController.text,
                'price': int.parse(_priceController.text),
                'stock': int.parse(_stockController.text),
                'category': _selectedCategory,
              });
            }
          },
          child: const Text("SIMPAN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Helper untuk TextField agar kode lebih bersih
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: _buildInputDecoration(label, icon),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFF00E0C6)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00E0C6)),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

//  void _openAddProductDialog(BuildContext context) async {
//     // 1. Munculkan dialog dan tunggu hasilnya
//     final result = await showDialog<Map<String, dynamic>>(
//       context: context,
//       builder: (context) => const AddProductDialog(),
//     );

//     // 2. Jika user menekan SIMPAN (result tidak null)
//     if (result != null) {
//       // 3. Kirim data ke Provider
//       // ignore: use_build_context_synchronously
//       await context.read<CafeProvider>().addProduct(result);

//       // 4. Beri feedback ke user
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Produk baru berhasil ditambahkan!")),
//         );
//       }
//     }
//   }