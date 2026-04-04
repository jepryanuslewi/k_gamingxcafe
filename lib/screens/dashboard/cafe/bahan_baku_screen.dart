import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/cafe/bahan_model.dart';
import 'package:k_gamingxcafe/providers/cafe/bahan_provider.dart';
import 'package:provider/provider.dart';

class BahanBakuScreen extends StatefulWidget {
  const BahanBakuScreen({super.key});

  @override
  State<BahanBakuScreen> createState() => _BahanBakuScreenState();
}

class _BahanBakuScreenState extends State<BahanBakuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BahanProvider>().fetchBahan();
    });
  }

  // --- UI DIALOG TAMBAH BAHAN ---
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
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(namaController, "Nama Bahan"),
                  _buildTextField(
                    kategoriController,
                    "Kategori (cth: Bubuk, Susu)",
                  ),
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
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffe21388),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newBahan = Bahan(
                    nama: namaController.text,
                    kategori: kategoriController.text,
                    satuan: selectedSatuan,
                    // Sekarang nilai input masuk ke stokSaatIni
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
    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Manajemen Bahan Baku",
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xffe21388),
          labelColor: const Color(0xffe21388),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.inventory), text: "Stok Bahan"),
            Tab(icon: Icon(Icons.history), text: "Riwayat"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffe21388),
        onPressed: showAddBahanForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStokTab(),
          const Center(
            child: Text(
              "Halaman Riwayat (Coming Soon)",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStokTab() {
    return Consumer<BahanProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading)
          return const Center(child: CircularProgressIndicator());
        if (provider.listBahan.isEmpty)
          return const Center(
            child: Text(
              "Belum ada bahan baku",
              style: TextStyle(color: Colors.white70),
            ),
          );

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.listBahan.length,
          itemBuilder: (context, index) {
            final bahan = provider.listBahan[index];
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
                    isEmpty ? Icons.warning_amber_rounded : Icons.kitchen,
                    color: isEmpty ? Colors.redAccent : Colors.cyanAccent,
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

                // --- BUTTON EDIT & DELETE DI SINI ---
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
                      onPressed: () {
                        // Tampilkan konfirmasi hapus
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
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

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
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updatedBahan = Bahan(
                    id: bahan.id, // ID lama wajib disertakan
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
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
