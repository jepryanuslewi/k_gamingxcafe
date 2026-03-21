import 'package:flutter/material.dart';

class AddMenuRecipeDialog extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients; // Daftar bahan mentah dari DB

  const AddMenuRecipeDialog({super.key, required this.ingredients});

  @override
  State<AddMenuRecipeDialog> createState() => _AddMenuRecipeDialogState();
}

class _AddMenuRecipeDialogState extends State<AddMenuRecipeDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controller Utama
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedCategory;

  // List untuk menampung baris resep secara dinamis
  List<Map<String, dynamic>> _recipeRows = [];

  void _addRecipeRow() {
    setState(() {
      _recipeRows.add({
        'ingredient_id': null,
        'usage_controller': TextEditingController(),
      });
    });
  }

  void _removeRecipeRow(int index) {
    setState(() {
      _recipeRows[index]['usage_controller'].dispose();
      _recipeRows.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    for (var row in _recipeRows) {
      row['usage_controller'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF141C2F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Menu Baru + Resep",
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 500, // Ukuran lebar untuk Tablet
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(
                  _nameController,
                  "Nama Menu",
                  Icons.restaurant_menu,
                ),
                const SizedBox(height: 10),
                _buildField(
                  _priceController,
                  "Harga Jual",
                  Icons.payments,
                  isNumber: true,
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xFF141C2F),
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Kategori", Icons.category),
                  items: ['Makanan', 'Minuman']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => _selectedCategory = val,
                  validator: (v) => v == null ? "Pilih kategori" : null,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(color: Colors.white24),
                ),

                const Text(
                  "Resep Bahan (Per Porsi)",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // List Dinamis Resep
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recipeRows.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          // Dropdown Pilih Bahan
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<int>(
                              dropdownColor: const Color(0xFF141C2F),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              decoration: _buildInputDecoration(
                                "Bahan",
                                Icons.inventory,
                              ),
                              items: widget.ingredients.map((ing) {
                                return DropdownMenuItem(
                                  value: ing['id'] as int,
                                  child: Text(ing['name']),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  _recipeRows[index]['ingredient_id'] = val,
                            ),
                          ),
                          const SizedBox(width: 5),
                          // Input Jumlah Pemakaian
                          Expanded(
                            child: TextFormField(
                              controller:
                                  _recipeRows[index]['usage_controller'],
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration(
                                "Qty",
                                Icons.scale,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _removeRecipeRow(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                TextButton.icon(
                  onPressed: _addRecipeRow,
                  icon: const Icon(Icons.add, color: Color(0xFF00E0C6)),
                  label: const Text(
                    "Tambah Bahan Resep",
                    style: TextStyle(color: Color(0xFF00E0C6)),
                  ),
                ),
              ],
            ),
          ),
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
              // Siapkan data resep untuk dikirim
              List<Map<String, dynamic>> finalRecipe = _recipeRows.map((row) {
                return {
                  'ingredient_id': row['ingredient_id'],
                  'usage_qty': int.parse(row['usage_controller'].text),
                };
              }).toList();

              Navigator.pop(context, {
                'product': {
                  'name': _nameController.text,
                  'price': int.parse(_priceController.text),
                  'category': _selectedCategory,
                  'stock':
                      999, // Untuk menu racikan, stok biasanya default tinggi
                },
                'recipe': finalRecipe,
              });
            }
          },
          child: const Text(
            "SIMPAN MENU",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _buildInputDecoration(label, icon),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFF00E0C6), size: 18),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF00E0C6)),
      ),
    );
  }
}

// void _openAddMenuDialog(BuildContext context) async {
//   final ingredientProvider = context.read<IngredientProvider>();

//   final result = await showDialog<Map<String, dynamic>>(
//     context: context,
//     builder: (context) =>
//         AddMenuRecipeDialog(ingredients: ingredientProvider.ingredients),
//   );

//   if (result != null) {
//     // Kirim ke CafeProvider untuk simpan Product + Recipes-nya sekaligus
//     await context.read<CafeProvider>().addProductWithRecipe(
//       result['product'],
//       result['recipe'],
//     );
//   }
// }
