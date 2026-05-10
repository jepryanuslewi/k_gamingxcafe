import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/cafe/bahan_model.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/cafe/bahan_provider.dart';
import 'package:k_gamingxcafe/widgets/stock/button_stock.dart';
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
      context.read<BahanProvider>().fetchRiwayatKeluar();
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
        const SnackBar(
          backgroundColor: Color.fromRGBO(226, 19, 136, 1.0),
          content: Center(
            child: Text(
              'Lengkapi data terlebih dahulu!',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final double? qty = double.tryParse(_stokController.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromRGBO(226, 19, 136, 1.0),
          content: Center(
            child: Text(
              'Jumlah pengurangan tidak valid!',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if ((selectedBahan?.stokSaatIni ?? 0) < qty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromRGBO(226, 19, 136, 1.0),
          content: Center(
            child: Text(
              'Stok tidak cukup! Sisa stok: ${selectedBahan?.stokSaatIni}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final authProv = context.read<AuthProvider>();
    final bahanProv = context.read<BahanProvider>();

    final success = await bahanProv.stokKeluar(
      bahanId: selectedBahan!.id!,
      jumlah: qty * (selectedBahan?.isiPerQty ?? 1.0),
      username: authProv.user?.username ?? "Unknown",
      namaShift: widget.shiftName,
      keterangan: _deskripsiController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF00E0C6),
          content: Center(
            child: Text(
              "Stok ${selectedBahan!.nama} berhasil dikurangi!",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
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
            color: Color.fromRGBO(226, 19, 136, 100),
          ),
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
              Image.asset("assets/images/bgLoginScreen.png", width: 100),
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
                      color: Color.fromRGBO(0, 224, 198, 100),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.person_pin,
                size: 50,
                color: Color.fromRGBO(0, 224, 198, 100),
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
                "STOK KELUAR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ButtonStock(
                text: "kembali",
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
                backgroundColor: Color.fromRGBO(226, 19, 136, 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: prov.isLoading ? null : _handleSimpan,
              child: const Text(
                "KURANGI STOK",
                style: TextStyle(
                  color: Colors.white,
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
    final now = DateTime.now();
    final riwayatHariIni = prov.listRiwayatKeluar.where((r) {
      if (r.waktu == null) return false;
      try {
        final dateWaktu = DateTime.parse(r.waktu!);
        return dateWaktu.year == now.year &&
            dateWaktu.month == now.month &&
            dateWaktu.day == now.day;
      } catch (e) {
        return false;
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
                rows: riwayatHariIni.asMap().entries.map((entry) {
                  final r = entry.value;
                  final double isiPerQty = (r.isiPerQty ?? 1).toDouble();
                  final double qty = r.jumlah! / isiPerQty;
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
                          "${qty.toStringAsFixed(0)} / ${r.jumlah} ${r.satuan}",
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
                          "${r.namaShift}",
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
