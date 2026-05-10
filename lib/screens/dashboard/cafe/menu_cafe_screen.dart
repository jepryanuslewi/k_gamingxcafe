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
    String? errorResep; // ✅ tambah ini

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final listBahan = context.watch<BahanProvider>().listBahan;

          return AlertDialog(
            backgroundColor: const Color(0xff141c2f),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            title: const Text(
              "Tambah Menu & Resep",
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
                      _buildTextField(
                        namaController,
                        "Nama Menu",
                        extraValidator: (v) {
                          final sudahAda = context
                              .read<MenuProvider>()
                              .listMenu
                              .any(
                                (m) =>
                                    m.nama.toLowerCase().trim() ==
                                    v!.toLowerCase().trim(),
                              );
                          return sudahAda ? "Menu '$v' sudah ada!" : null;
                        },
                      ),
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
                                errorResep = null; // ✅ reset error saat tambah
                              });
                            },
                            icon: const Icon(
                              Icons.add_circle,
                              color: Color(0xffe21388),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24),

                      // ✅ Tampilkan error resep di dalam dialog
                      if (errorResep != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: Text(
                            errorResep!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

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
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setModalState(() {
                                      resepInput[index]['bahan_id'] = val;
                                      errorResep = null; // ✅ reset error
                                    }),
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
                                  onChanged: (_) => setModalState(
                                    () => errorResep = null, // ✅ reset error
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: "Qty",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
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
                                onPressed: () => setModalState(() {
                                  resepInput.removeAt(index);
                                  errorResep = null; // ✅ reset error
                                }),
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
                  if (!formKey.currentState!.validate()) return;

                  if (resepInput.isEmpty) {
                    setModalState(
                      () => errorResep = "Resep bahan tidak boleh kosong!",
                    );
                    return;
                  }

                  for (int i = 0; i < resepInput.length; i++) {
                    final bahanId = resepInput[i]['bahan_id'];
                    final controller =
                        resepInput[i]['jumlah'] as TextEditingController;
                    final qty = double.tryParse(controller.text);

                    if (bahanId == null) {
                      setModalState(
                        () => errorResep = "Bahan ke-${i + 1} belum dipilih!",
                      );
                      return;
                    }

                    if (controller.text.isEmpty || qty == null || qty <= 0) {
                      setModalState(
                        () => errorResep = "Qty bahan ke-${i + 1} tidak valid!",
                      );
                      return;
                    }
                  }

                  final bahanIds = resepInput
                      .map((r) => r['bahan_id'])
                      .toList();
                  if (bahanIds.length != bahanIds.toSet().length) {
                    setModalState(
                      () => errorResep = "Ada bahan yang sama di resep!",
                    );
                    return;
                  }

                  final menuBaru = MenuModel(
                    nama: namaController.text,
                    harga: double.parse(hargaController.text),
                    kategori: selectedKategori,
                  );

                  await context.read<MenuProvider>().addMenuWithResep(
                    menuBaru,
                    resepInput,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color.fromRGBO(226, 19, 136, 1.0),
                      content: Center(
                        child: Text(
                          'Menu baru berhasil ditambahkan!',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  if (context.mounted) Navigator.pop(context);
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
    String? Function(String?)? extraValidator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "Wajib diisi";
        if (extraValidator != null) return extraValidator(v);
        return null;
      },
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

      body: menuProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  const Text(
                    "Kelola Menu Cafe",
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
                  Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffe21388),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: showAddMenuForm,
                      child: Text(
                        "Tambah Menu",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
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
                                            color: Colors.cyanAccent,
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
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor: const Color(
                                                  0xff141c2f,
                                                ),
                                                title: const Text(
                                                  "Hapus Menu?",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                content: Text(
                                                  "Yakin ingin menghapus menu '${menu.nama}'?\n\n"
                                                  "⚠️ Resep bahan yang terkait akan ikut terhapus.",
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text(
                                                      "Batal",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      await menuProvider
                                                          .removeMenu(menu.id!);
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          backgroundColor:
                                                              Color.fromRGBO(
                                                                226,
                                                                19,
                                                                136,
                                                                1.0,
                                                              ),
                                                          content: Center(
                                                            child: Text(
                                                              'Menu berhasil dihapus!',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                          duration: Duration(
                                                            seconds: 2,
                                                          ),
                                                        ),
                                                      );
                                                      if (context.mounted)
                                                        Navigator.pop(context);
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
                  ),
                ],
              ),
            ),
    );
  }

  void showEditMenuForm(MenuModel menu) async {
    final namaController = TextEditingController(text: menu.nama);
    final hargaController = TextEditingController(
      text: menu.harga.toInt().toString(),
    );
    String selectedKategori = menu.kategori;
    final formKey = GlobalKey<FormState>();
    String? errorResep;

    final resepLama = await DatabaseService.instance.getResepByProductId(
      menu.id!,
    );

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
                      _buildTextField(
                        namaController,
                        "Nama Menu",
                        extraValidator: (v) {
                          final sudahAda = context
                              .read<MenuProvider>()
                              .listMenu
                              .any(
                                (m) =>
                                    m.nama.toLowerCase().trim() ==
                                        v!.toLowerCase().trim() &&
                                    m.id != menu.id,
                              );
                          return sudahAda ? "Menu '$v' sudah ada!" : null;
                        },
                      ),
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
                                errorResep = null;
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

                      if (errorResep != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: Text(
                            errorResep!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

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
                                    onChanged: (val) => setModalState(() {
                                      resepInput[index]['bahan_id'] = val;
                                      errorResep = null; // ✅ reset error
                                    }),
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
                                  onChanged: (_) =>
                                      setModalState(() => errorResep = null),
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
                                onPressed: () => setModalState(() {
                                  resepInput.removeAt(index);
                                  errorResep = null; // ✅ reset error
                                }),
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
                  backgroundColor: const Color.fromRGBO(0, 224, 198, 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  if (resepInput.isEmpty) {
                    setModalState(
                      () => errorResep = "Resep bahan tidak boleh kosong!",
                    );
                    return;
                  }

                  for (int i = 0; i < resepInput.length; i++) {
                    final bahanId = resepInput[i]['bahan_id'];
                    final controller =
                        resepInput[i]['jumlah'] as TextEditingController;
                    final qty = double.tryParse(controller.text);

                    if (bahanId == null) {
                      setModalState(
                        () => errorResep = "Bahan ke-${i + 1} belum dipilih!",
                      );
                      return;
                    }

                    if (controller.text.isEmpty || qty == null || qty <= 0) {
                      setModalState(
                        () => errorResep = "Qty bahan ke-${i + 1} tidak valid!",
                      );
                      return;
                    }
                  }

                  final bahanIds = resepInput
                      .map((r) => r['bahan_id'])
                      .toList();
                  if (bahanIds.length != bahanIds.toSet().length) {
                    setModalState(
                      () => errorResep = "Ada bahan yang sama di resep!",
                    );
                    return;
                  }

                  final menuUpdate = MenuModel(
                    id: menu.id,
                    nama: namaController.text,
                    harga: double.parse(hargaController.text),
                    kategori: selectedKategori,
                    stok: menu.stok,
                  );

                  await context.read<MenuProvider>().updateMenuLengkap(
                    menuUpdate,
                    resepInput,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color.fromRGBO(226, 19, 136, 1.0),
                        content: Center(
                          child: Text(
                            'Menu berhasil diperbarui!',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
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
