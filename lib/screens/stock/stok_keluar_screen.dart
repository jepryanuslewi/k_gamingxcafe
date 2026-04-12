import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/cafe/bahan_model.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/cafe/bahan_provider.dart';
import 'package:k_gamingxcafe/widgets/stock/dropdown_search_widget.dart';
import 'package:provider/provider.dart';

class StockKeluarScreen extends StatefulWidget {
  final String shiftName;
  const StockKeluarScreen({super.key, required this.shiftName});

  @override
  State<StockKeluarScreen> createState() => _StockKeluarScreenState();
}

class _StockKeluarScreenState extends State<StockKeluarScreen> {
  Bahan? selectedBahan;
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BahanProvider>().fetchBahan();
      context
          .read<BahanProvider>()
          .fetchRiwayatKeluar(); // Ambil riwayat khusus keluar
    });
  }

  @override
  void dispose() {
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _handleSimpan() async {
    if (selectedBahan == null || _stokController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi data terlebih dahulu!")),
      );
      return;
    }

    final double? qty = double.tryParse(_stokController.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jumlah pengurangan tidak valid!")),
      );
      return;
    }

    // Validasi tambahan: Cek apakah stok cukup sebelum dikurangi
    if ((selectedBahan?.stokSaatIni ?? 0) < qty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Stok tidak cukup! Sisa stok: ${selectedBahan?.stokSaatIni}",
          ),
        ),
      );
      return;
    }

    final authProv = context.read<AuthProvider>();
    final bahanProv = context.read<BahanProvider>();

    final success = await bahanProv.stokKeluar(
      bahanId: selectedBahan!.id!,
      jumlah: qty,
      username: authProv.user?.username ?? "Unknown",
      namaShift: widget.shiftName,
      keterangan: _deskripsiController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Stok ${selectedBahan!.nama} berhasil dikurangi!"),
        ),
      );
      setState(() {
        selectedBahan = null;
        _stokController.clear();
        _deskripsiController.clear();
      });
    }
  }

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
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        filled: true,
        fillColor: const Color.fromRGBO(26, 37, 64, 1),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.orangeAccent,
          ), // Warna oranye untuk "Keluar"
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
    final prov = context.watch<BahanProvider>();
    final tanggal = DateTime.now();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 18, 32, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              _buildHeader(authprovider.user?.username ?? "User"),
              const SizedBox(height: 20),
              _buildFormInput(tanggal, prov),
              const SizedBox(height: 25),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "RIWAYAT PENGURANGAN STOK HARI INI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(child: _buildTableRiwayat(prov)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

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
                "STOCK OUT",
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
                      color: Colors.orangeAccent,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.person_pin,
                size: 50,
                color: Colors.orangeAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

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
                "INPUT STOK KELUAR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${tanggal.day}/${tanggal.month}/${tanggal.year}",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownBahanWidget(
                  label: "keluar",
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
                  label: "Keterangan",
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
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: prov.isLoading ? null : _handleSimpan,
              child: const Text(
                "KURANGI STOK",
                style: TextStyle(
                  color: Colors.black,
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

  Widget _buildTableRiwayat(BahanProvider prov) {
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
                      "JAM",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                rows: prov.listRiwayatKeluar.asMap().entries.map((entry) {
                  final r = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          "${entry.key + 1}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      DataCell(
                        Text(
                          r.namaBahan ?? "-",
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
