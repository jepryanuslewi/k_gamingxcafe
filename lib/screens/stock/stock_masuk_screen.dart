import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/cafe/bahan_model.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/cafe/bahan_provider.dart';
import 'package:k_gamingxcafe/widgets/stock/button_stock.dart';
import 'package:k_gamingxcafe/widgets/stock/dropdown_search_widget.dart';
import 'package:provider/provider.dart';

class StockMasukScreen extends StatefulWidget {
  final String shiftName;
  const StockMasukScreen({super.key, required this.shiftName});

  @override
  State<StockMasukScreen> createState() => _StockMasukScreenState();
}

class _StockMasukScreenState extends State<StockMasukScreen> {
  Bahan? selectedBahan;
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Memastikan data di-fetch saat layar dibuka
    Future.microtask(() {
      context.read<BahanProvider>().fetchBahan();
      context.read<BahanProvider>().fetchRiwayatMasuk();
    });
  }

  @override
  void dispose() {
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // TAMBAHKAN FUNGSI INI DI DALAM _StockMasukScreenState
  Future<void> _handleSimpan() async {
    // 1. Validasi Input
    if (selectedBahan == null || _stokController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi data terlebih dahulu!")),
      );
      return;
    }

    final double? qty = double.tryParse(_stokController.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Jumlah stok tidak valid!")));
      return;
    }

    // 2. Ambil data dari Provider
    final authProv = context.read<AuthProvider>();
    final bahanProv = context.read<BahanProvider>();
    final String username = authProv.user?.username ?? "Unknown";

    // 3. Eksekusi fungsi Provider
    final success = await bahanProv.stokMasuk(
      bahanId: selectedBahan!.id!,
      jumlah: qty,
      username: username,
      namaShift: widget.shiftName,
      keterangan: _deskripsiController.text,
    );

    // 4. Respon UI
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("Stok ${selectedBahan!.nama} berhasil ditambahkan!"),
        ),
      );

      // Reset Form
      setState(() {
        selectedBahan = null;
        _stokController.clear();
        _deskripsiController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Gagal menambahkan stok. Coba lagi."),
        ),
      );
    }
  }

  // --- WIDGET HELPER ---
  Widget _buildStyledTextField({
    required String label,
    required TextEditingController controller,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontFamily: "Poppins"),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontFamily: "Poppins",
          fontSize: 12,
        ),
        filled: true,
        fillColor: const Color.fromRGBO(26, 37, 64, 1),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromRGBO(0, 224, 198, 1)),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authprovider = context.watch<AuthProvider>();
    final String username = authprovider.user?.username ?? "User";
    final prov = context.watch<BahanProvider>();
    final tanggal = DateTime.now();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 18, 32, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              _buildHeader(username),
              const SizedBox(height: 20),
              _buildFormInput(tanggal, prov),
              const SizedBox(height: 25),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "RIWAYAT STOK MASUK HARI INI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // TABEL MENGGUNAKAN EXPANDED AGAR MENGISI SISA RUANG
              Expanded(child: _buildTableRiwayat(prov)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- SUB-WIDGET: HEADER ---
  Widget _buildHeader(String username) {
    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset("assets/images/bgLoginScreen.png", height: 50),
              const SizedBox(width: 15),
              const Text(
                "STOCK MANAGEMENT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                ),
              ),
            ],
          ),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.shiftName,
                    style: const TextStyle(
                      color: Color.fromRGBO(0, 224, 198, 1),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.person_pin,
                size: 50,
                color: Color.fromRGBO(0, 224, 198, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- SUB-WIDGET: FORM INPUT ---
  Widget _buildFormInput(DateTime tanggal, BahanProvider prov) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(20, 28, 47, 1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "INPUT STOK MASUK",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ButtonStock(
                text: "Kembali",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownBahanWidget(
                  label: "masuk",
                  items: prov.listBahan,
                  selectedItem: selectedBahan,
                  isLoading: prov.isLoading,
                  onSelected: (val) => setState(() => selectedBahan = val),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStyledTextField(
                  label: "Qty",
                  controller: _stokController,
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStyledTextField(
                  label: "Ket/Deskripsi",
                  controller: _deskripsiController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 224, 198, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: prov.isLoading ? null : _handleSimpan,
              child: const Text(
                "TAMBAH STOK",
                style: TextStyle(
                  color: Color.fromRGBO(20, 28, 47, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUB-WIDGET: TABEL RIWAYAT ---
  // --- SUB-WIDGET: TABEL RIWAYAT ---
  Widget _buildTableRiwayat(BahanProvider prov) {
    if (prov.isLoading && prov.listRiwayat.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color.fromRGBO(0, 224, 198, 1)),
      );
    }

    // 1. Ambil waktu saat ini
    final now = DateTime.now();

    // 2. Filter listRiwayat hanya untuk hari ini
    final riwayatHariIni = prov.listRiwayat.where((r) {
      if (r.waktu == null) return false;
      try {
        // Asumsi format r.waktu bisa di-parse oleh DateTime (contoh: "2024-05-20 14:30:00")
        final dateWaktu = DateTime.parse(r.waktu!);
        // Cocokkan tahun, bulan, dan hari
        return dateWaktu.year == now.year &&
            dateWaktu.month == now.month &&
            dateWaktu.day == now.day;
      } catch (e) {
        return false; // Jika format waktu salah, jangan tampilkan agar tidak error
      }
    }).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(20, 28, 47, 1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 80,
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color.fromRGBO(26, 37, 64, 1),
                ),
                columnSpacing: 20,
                columns: const [
                  DataColumn(
                    label: Text(
                      "NO",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "BAHAN",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "KATEGORI",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "QTY",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "USER",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "SHIFT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "JAM",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                // 3. Gunakan list yang sudah di-filter: riwayatHariIni (bukan prov.listRiwayat)
                rows: riwayatHariIni.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final r = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          "$index",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      DataCell(
                        Text(
                          r.namaBahan ?? "ID: ${r.id}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${r.kategori}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${r.jumlah}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${r.username}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          r.namaShift ?? "-",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      DataCell(
                        Text(
                          r.waktu?.substring(11, 16) ?? "--:--",
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
