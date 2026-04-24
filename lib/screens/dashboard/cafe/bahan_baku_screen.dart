import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/cafe/bahan_model.dart';
import 'package:k_gamingxcafe/providers/cafe/bahan_provider.dart';
import 'package:provider/provider.dart';

class BahanBakuScreen extends StatefulWidget {
  const BahanBakuScreen({super.key});

  @override
  State<BahanBakuScreen> createState() => _BahanBakuScreenState();
}

class _BahanBakuScreenState extends State<BahanBakuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BahanProvider>().fetchBahan();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================= FORM TAMBAH =================
  void showAddBahanForm() {
    final namaController = TextEditingController();
    final kategoriController = TextEditingController();
    final stokController = TextEditingController();
    String selectedSatuan = "gram";
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xff141c2f),
          title: const Text(
            "Tambah Bahan Baku",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.30,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(namaController, "Nama Bahan"),
                    _buildTextField(kategoriController, "Kategori"),
                    _buildTextField(
                      stokController,
                      "Jumlah Stok",
                      isNumber: true,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xff141c2f),
                      value: selectedSatuan,
                      style: const TextStyle(color: Colors.white),
                      items: ["gram", "ml", "pcs", "kg"]
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setModalState(() => selectedSatuan = val!),
                      decoration: const InputDecoration(
                        labelText: "Satuan",
                        labelStyle: TextStyle(color: Colors.grey),
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
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffe21388),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newBahan = Bahan(
                    nama: namaController.text,
                    kategori: kategoriController.text,
                    satuan: selectedSatuan,
                    stokSaatIni: double.tryParse(stokController.text) ?? 0,
                  );
                  context.read<BahanProvider>().addBahan(newBahan);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Simpan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FORM EDIT =================
  void showEditBahanForm(Bahan bahan) {
    final namaController = TextEditingController(text: bahan.nama);
    final kategoriController = TextEditingController(text: bahan.kategori);
    final stokController = TextEditingController(
      text: bahan.stokSaatIni.toString(),
    );
    String selectedSatuan = bahan.satuan;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xff141c2f),
          title: const Text(
            "Edit Bahan Baku",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.30,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(namaController, "Nama Bahan"),
                    _buildTextField(kategoriController, "Kategori"),
                    _buildTextField(
                      stokController,
                      "Jumlah Stok",
                      isNumber: true,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xff141c2f),
                      value: selectedSatuan,
                      style: const TextStyle(color: Colors.white),
                      items: ["gram", "ml", "pcs", "kg"]
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setModalState(() => selectedSatuan = val!),
                      decoration: const InputDecoration(
                        labelText: "Satuan",
                        labelStyle: TextStyle(color: Colors.grey),
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
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffe21388),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updatedBahan = Bahan(
                    id: bahan.id,
                    nama: namaController.text,
                    kategori: kategoriController.text,
                    satuan: selectedSatuan,
                    stokSaatIni: double.tryParse(stokController.text) ?? 0,
                  );
                  context.read<BahanProvider>().updateBahan(updatedBahan);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Update",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
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

  // ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffe21388),
        onPressed: showAddBahanForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
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
            // 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Cari bahan atau kategori...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xff1c273d),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Consumer<BahanProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredList = provider.listBahan.where((bahan) {
                    return bahan.nama.toLowerCase().contains(_searchQuery) ||
                        bahan.kategori.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? "Belum ada bahan baku"
                            : "Pencarian tidak ditemukan",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(top: 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final bahan = filteredList[index];
                      bool isEmpty = bahan.stokSaatIni <= 0;

                      return Card(
                        color: const Color(0xff1c273d),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isEmpty
                                ? Colors.red.withOpacity(0.2)
                                : Colors.cyan.withOpacity(0.2),
                            child: Icon(
                              isEmpty
                                  ? Icons.warning_amber_rounded
                                  : Icons.kitchen,
                              color: isEmpty
                                  ? Colors.redAccent
                                  : Colors.cyanAccent,
                            ),
                          ),
                          title: Text(
                            bahan.nama,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "${bahan.stokSaatIni} ${bahan.satuan} - ${bahan.kategori}",
                            style: const TextStyle(color: Colors.white60),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                onPressed: () => showEditBahanForm(bahan),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    _confirmDelete(provider, bahan),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BahanProvider provider, Bahan bahan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff141c2f),
        title: const Text(
          "Hapus Bahan?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Yakin ingin menghapus ${bahan.nama}?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              provider.deleteBahan(bahan.id!);
              Navigator.pop(context);
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
