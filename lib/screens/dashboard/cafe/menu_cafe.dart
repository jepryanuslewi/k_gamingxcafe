import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:k_gamingxcafe/providers/cafe/bahan_provider.dart';
import 'package:k_gamingxcafe/providers/cafe/menu_provider.dart';
import 'package:k_gamingxcafe/models/cafe/menu_model.dart';

class MenuCafe extends StatefulWidget {
  const MenuCafe({super.key});

  @override
  State<MenuCafe> createState() => _MenuCafeState();
}

class _MenuCafeState extends State<MenuCafe> {
  final List<String> kategoriMenu = ["Minuman", "Makanan"];
  List<Map<String, dynamic>> resepInput = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BahanProvider>().fetchBahan();
      context.read<MenuProvider>().fetchMenu();
    });
  }

  void showAddMenuForm() {
    final namaController = TextEditingController();
    final hargaController = TextEditingController();
    String selectedKategori = kategoriMenu[0];
    final formKey = GlobalKey<FormState>();
    resepInput = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Mengambil data bahan dari provider secara reaktif
          final listBahan = context.watch<BahanProvider>().listBahan;

          return AlertDialog(
            backgroundColor: const Color(0xff141c2f),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ), // Biar gak terlalu lebar ke samping
            title: const Text(
              "Tambah Menu & Resep",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width:
                  MediaQuery.of(context).size.width *
                  0.85, // Batasi lebar dialog
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(namaController, "Nama Menu"),
                      _buildTextField(
                        hargaController,
                        "Harga Jual",
                        isNumber: true,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xff141c2f),
                        value: selectedKategori,
                        style: const TextStyle(color: Colors.white),
                        items: kategoriMenu
                            .map(
                              (k) => DropdownMenuItem(value: k, child: Text(k)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setModalState(() => selectedKategori = val!),
                        decoration: const InputDecoration(
                          labelText: "Kategori",
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Resep Bahan",
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setModalState(() {
                                resepInput.add({
                                  "bahan_id": null,
                                  "jumlah": TextEditingController(),
                                });
                              });
                            },
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.cyanAccent,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24),

                      // List Inputan Bahan Dinamis
                      if (resepInput.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Belum ada bahan resep",
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      ...resepInput.asMap().entries.map((entry) {
                        int index = entry.key;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              // Dropdown Pilih Bahan Baku
                              Expanded(
                                flex: 3,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    dropdownColor: const Color(0xff141c2f),
                                    hint: const Text(
                                      "Pilih Bahan",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    value: resepInput[index]['bahan_id'],
                                    items: listBahan.map((b) {
                                      return DropdownMenuItem(
                                        value: b.id,
                                        child: Text(
                                          "${b.nama} (${b.satuan})",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setModalState(
                                      () => resepInput[index]['bahan_id'] = val,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Input Jumlah
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: resepInput[index]['jumlah'],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Qty",
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    isDense: true,
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () => setModalState(
                                  () => resepInput.removeAt(index),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff00E0C6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final menuBaru = MenuModel(
                      nama: namaController.text,
                      harga: double.parse(hargaController.text),
                      kategori: selectedKategori,
                    );

                    // Eksekusi Simpan di Provider
                    await context.read<MenuProvider>().addMenuWithResep(
                      menuBaru,
                      resepInput,
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Simpan",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();

    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Kelola Menu Cafe",
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff00E0C6),
        onPressed: showAddMenuForm,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: menuProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menuProvider.listMenu.length,
              itemBuilder: (context, index) {
                final menu = menuProvider.listMenu[index];
                return Card(
                  color: const Color(0xff1c273d),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0x2200E0C6),
                      child: Icon(Icons.fastfood, color: Color(0xff00E0C6)),
                    ),
                    title: Text(
                      menu.nama,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Rp ${menu.harga.toInt()}",
                      style: const TextStyle(color: Colors.white60),
                    ),
                    trailing: SizedBox(
                      width: 100, // Beri lebar agar cukup untuk 2 tombol
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // TOMBOL EDIT
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.amber,
                            ),
                            onPressed: () =>
                                showEditMenuForm(menu), // Panggil form edit
                          ),
                          // TOMBOL DELETE
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (confirmContext) => AlertDialog(
                                  backgroundColor: const Color(0xff141c2f),
                                  title: const Text(
                                    "Hapus Bahan?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  content: const Text(
                                    "Yakin ingin menghapus bahan ini dari resep?",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(confirmContext),
                                      child: const Text(
                                        "Batal",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Tutup dialog konfirmasi
                                        Navigator.pop(confirmContext);

                                        menuProvider.removeMenu(menu.id!);
                                      },
                                      child: const Text(
                                        "Hapus",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void showEditMenuForm(MenuModel menu) async {
    // 1. Inisialisasi Controller dengan data menu lama
    final namaController = TextEditingController(text: menu.nama);
    final hargaController = TextEditingController(
      text: menu.harga.toInt().toString(),
    );
    String selectedKategori = menu.kategori;
    final formKey = GlobalKey<FormState>();

    // 2. Ambil resep lama dari Database (Opsional: Tampilkan loading jika resep banyak)
    final resepLama = await DatabaseService.instance.getResepByProductId(
      menu.id!,
    );

    // 3. Map data resep lama ke dalam resepInput agar muncul di UI
    setState(() {
      resepInput = resepLama.map((r) {
        return {
          "bahan_id": r['bahan_id'],
          "jumlah": TextEditingController(text: r['jumlah_pakai'].toString()),
        };
      }).toList();
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Di sini variabel ini digunakan untuk mengisi dropdown
          final listBahan = context.watch<BahanProvider>().listBahan;

          return AlertDialog(
            backgroundColor: const Color(0xff141c2f),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            title: const Text(
              "Update Menu & Resep",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(namaController, "Nama Menu"),
                      _buildTextField(
                        hargaController,
                        "Harga Jual",
                        isNumber: true,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xff141c2f),
                        value: selectedKategori,
                        style: const TextStyle(color: Colors.white),
                        items: kategoriMenu
                            .map(
                              (k) => DropdownMenuItem(value: k, child: Text(k)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setModalState(() => selectedKategori = val!),
                        decoration: const InputDecoration(
                          labelText: "Kategori",
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Edit Resep Bahan",
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setModalState(() {
                                resepInput.add({
                                  "bahan_id": null,
                                  "jumlah": TextEditingController(),
                                });
                              });
                            },
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.amberAccent,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24),

                      // LIST INPUTAN BAHAN (Sama seperti di Add Menu)
                      if (resepInput.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Belum ada bahan resep",
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      ...resepInput.asMap().entries.map((entry) {
                        int index = entry.key;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    dropdownColor: const Color(0xff141c2f),
                                    hint: const Text(
                                      "Pilih Bahan",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    value: resepInput[index]['bahan_id'],
                                    items: listBahan.map((b) {
                                      return DropdownMenuItem(
                                        value: b.id,
                                        child: Text(
                                          "${b.nama} (${b.satuan})",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setModalState(
                                      () => resepInput[index]['bahan_id'] = val,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: resepInput[index]['jumlah'],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: "Qty",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () => setModalState(
                                  () => resepInput.removeAt(index),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.amber, // Warna berbeda untuk membedakan Edit & Add
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final menuUpdate = MenuModel(
                      id: menu.id, // Pastikan ID lama disertakan
                      nama: namaController.text,
                      harga: double.parse(hargaController.text),
                      kategori: selectedKategori,
                      stok: menu.stok,
                    );

                    // Panggil fungsi update lengkap di Provider
                    await context.read<MenuProvider>().updateMenuLengkap(
                      menuUpdate,
                      resepInput,
                    );

                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Update Data",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
