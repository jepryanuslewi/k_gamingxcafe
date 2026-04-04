import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> units = [];
  List<Map<String, dynamic>> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final db = await DatabaseService.instance.database;

    final unitData = await db.query("ps_units", orderBy: "name ASC");
    final packageData = await db.query("packages", orderBy: "price ASC");

    setState(() {
      units = unitData;
      packages = packageData;
      isLoading = false;
    });
  }

  // --- LOGIKA UNIT ---
  Future<void> deleteUnit(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete("ps_units", where: "id = ?", whereArgs: [id]);
    loadData();
  }

  // --- LOGIKA PACKAGE ---
  Future<void> deletePackage(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete("packages", where: "id = ?", whereArgs: [id]);
    loadData();
  }

  // --- UI DIALOG TAMBAH (Disesuaikan berdasarkan Tab aktif) ---
  void showAddForm() {
    if (_tabController.index == 0) {
      showAddUnitForm();
    } else {
      showAddPackageForm();
    }
  }

  // Form Unit (Sudah Anda miliki)
  void showAddUnitForm() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // PERBAIKAN 1: Samakan dengan salah satu isi items (Case Sensitive)
    String type = "REGULAR";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xff141c2f),
          title: const Text(
            "Tambah Unit Baru",
            style: TextStyle(color: Colors.white),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Nama Unit",
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                TextFormField(
                  controller: priceController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Harga per Jam",
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 15), // Tambahkan sedikit jarak
                DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xff141c2f),
                  initialValue: type,
                  style: const TextStyle(color: Colors.white),
                  // PERBAIKAN 2: Gunakan list yang konsisten
                  items: ["REGULAR", "VIP 1", "VIP 2"]
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t,
                          ), // Tidak perlu .toUpperCase() lagi karena sudah besar
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setModalState(() => type = val!),
                  decoration: const InputDecoration(
                    labelText: "Tipe",
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final db = await DatabaseService.instance.database;
                    await db.insert("ps_units", {
                      "name": nameController.text,
                      "type": type,
                      "price_per_hour": int.parse(priceController.text),
                      "status": "idle",
                      "duration_seconds": 0,
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      loadData();
                    }
                  } catch (e) {
                    // Tangkap error jika parse angka gagal
                    print("Error saat simpan: $e");
                  }
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  // Form Package (Baru)
  void showAddPackageForm() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff141c2f),
        title: const Text(
          "Tambah Paket Event",
          style: TextStyle(color: Colors.white),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Nama Paket Promo",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                controller: durationController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Durasi (Jam)",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                controller: priceController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Harga Paket",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final db = await DatabaseService.instance.database;
                await db.insert("packages", {
                  "name": nameController.text,
                  "price": int.parse(priceController.text),
                  "duration_hours": int.parse(durationController.text),
                });
                Navigator.pop(context);
                loadData();
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      appBar: AppBar(
        title: const Text(
          "Manajemen PS UNIT & PAKET",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xffe21388),
          tabs: const [
            Tab(icon: Icon(Icons.tv), text: "Unit PS"),
            Tab(icon: Icon(Icons.confirmation_number), text: "Paket Event"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffe21388),
        onPressed: showAddForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: GRID UNIT
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: units.length,
                  itemBuilder: (context, index) => unitCard(units[index]),
                ),
                // TAB 2: LIST PACKAGE
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final pkg = packages[index];
                    return Card(
                      color: const Color(0xff1c273d),
                      child: ListTile(
                        title: Text(
                          pkg["name"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${pkg["duration_hours"]} Jam - Rp ${pkg["price"]}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => deletePackage(pkg["id"]),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  // Widget unitCard tetap sama seperti kode Anda sebelumnya...
  Widget unitCard(Map unit) {
    final String status = unit["status"] ?? "idle";
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff1c273d),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit["name"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  unit["type"].toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                const Divider(color: Colors.white12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rp ${unit["price_per_hour"]}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    // ... sisanya sama ...
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.white24, size: 20),
              onPressed: () => deleteUnit(unit["id"]),
            ),
          ),
        ],
      ),
    );
  }
}
