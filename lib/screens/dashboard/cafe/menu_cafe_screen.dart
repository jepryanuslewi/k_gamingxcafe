import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:k_gamingxcafe/providers/cafe/bahan_provider.dart';
import 'package:k_gamingxcafe/providers/cafe/menu_provider.dart';
import 'package:k_gamingxcafe/models/cafe/menu_model.dart';

class MenuCafeScreen extends StatefulWidget {
  const MenuCafeScreen({super.key});

  @override
  State<MenuCafeScreen> createState() => _MenuCafeScreenState();
}

class _MenuCafeScreenState extends State<MenuCafeScreen> {
  final List<String> kategoriMenu = ["Minuman", "Makanan"];
  List<Map<String, dynamic>> resepInput = [];

  // ✅ SEARCH
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

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
                  0.40, // Batasi lebar dialog
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
                  backgroundColor: const Color(0xffe21388),
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
                    color: Colors.white,
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
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();

    // ✅ FILTER MENU
    final filteredMenu = menuProvider.listMenu.where((menu) {
      return menu.nama.toLowerCase().contains(searchQuery) ||
          menu.kategori.toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffe21388),
        onPressed: showAddMenuForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: menuProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  const Text(
                    "Kelola Bahan Baku",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: const [
                      Text(
                        "GAMING",
                        style: TextStyle(
                          color: Color.fromRGBO(226, 19, 136, 100),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "X",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "CAFE",
                        style: TextStyle(
                          color: Color.fromRGBO(0, 224, 198, 100),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.white10, thickness: 1, height: 32),
                  SizedBox(height: 10),
                  // ✅ SEARCH BAR
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Cari menu...",
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),
                        filled: true,
                        fillColor: const Color(0xff1c273d),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  Expanded(
                    child: filteredMenu.isEmpty
                        ? const Center(
                            child: Text(
                              "Menu tidak ditemukan",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 16),
                            itemCount: filteredMenu.length,
                            itemBuilder: (context, index) {
                              final menu = filteredMenu[index];

                              return Card(
                                color: const Color(0xff1c273d),
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0x2200E0C6),
                                    child: Icon(
                                      Icons.fastfood,
                                      color: Color(0xff00E0C6),
                                    ),
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
                                    style: const TextStyle(
                                      color: Colors.white60,
                                    ),
                                  ),
                                  trailing: SizedBox(
                                    width: 100,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: Colors.amber,
                                          ),
                                          onPressed: () =>
                                              showEditMenuForm(menu),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            menuProvider.removeMenu(menu.id!);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
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
              width: MediaQuery.of(context).size.width * 0.40,
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
                              color: Colors.grey,
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
                  backgroundColor: const Color(0xffe21388),
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
                    color: Colors.white,
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
