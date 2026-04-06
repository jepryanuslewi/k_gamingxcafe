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
    if (!mounted) return;
    setState(() => isLoading = true);
    final db = await DatabaseService.instance.database;

    final unitData = await db.query("ps_units", orderBy: "name ASC");
    final packageData = await db.query("packages", orderBy: "price ASC");

    if (mounted) {
      setState(() {
        units = unitData;
        packages = packageData;
        isLoading = false;
      });
    }
  }

  // --- LOGIKA DELETE ---
  Future<void> deleteUnit(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete("ps_units", where: "id = ?", whereArgs: [id]);
    loadData();
  }

  Future<void> deletePackage(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete("packages", where: "id = ?", whereArgs: [id]);
    loadData();
  }

  // --- LOGIKA EDIT UNIT ---
  void showEditUnitForm(Map<String, dynamic> unit) {
    final nameController = TextEditingController(text: unit["name"]);
    final priceController = TextEditingController(
      text: unit["price_per_hour"].toString(),
    );
    final formKey = GlobalKey<FormState>();
    String type = unit["type"];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xff141c2f),
          title: Text(
            "Edit Unit: ${unit['name']}",
            style: const TextStyle(color: Colors.white),
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
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xff141c2f),
                  value: type,
                  style: const TextStyle(color: Colors.white),
                  items: ["REGULAR", "VIP 1", "VIP 2"]
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
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
                  final db = await DatabaseService.instance.database;
                  await db.update(
                    "ps_units",
                    {
                      "name": nameController.text,
                      "type": type,
                      "price_per_hour": int.parse(priceController.text),
                    },
                    where: "id = ?",
                    whereArgs: [unit["id"]],
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    loadData();
                  }
                }
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIKA EDIT PAKET ---
  void showEditPackageForm(Map<String, dynamic> pkg) {
    final nameController = TextEditingController(text: pkg["name"]);
    final priceController = TextEditingController(
      text: pkg["price"].toString(),
    );
    final durationController = TextEditingController(
      text: pkg["duration_hours"].toString(),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff141c2f),
        title: Text(
          "Edit Paket: ${pkg['name']}",
          style: const TextStyle(color: Colors.white),
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
                  labelText: "Nama Paket",
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
                await db.update(
                  "packages",
                  {
                    "name": nameController.text,
                    "price": int.parse(priceController.text),
                    "duration_hours": int.parse(durationController.text),
                  },
                  where: "id = ?",
                  whereArgs: [pkg["id"]],
                );
                if (mounted) {
                  Navigator.pop(context);
                  loadData();
                }
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // --- UI DIALOG TAMBAH ---
  void showAddForm() {
    if (_tabController.index == 0) {
      showAddUnitForm();
    } else {
      showAddPackageForm();
    }
  }

  void showAddUnitForm() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
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
                ),
                TextFormField(
                  controller: priceController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Harga per Jam",
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xff141c2f),
                  value: type,
                  style: const TextStyle(color: Colors.white),
                  items: ["REGULAR", "VIP 1", "VIP 2"]
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
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
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

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
                  labelText: "Nama Paket",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              TextFormField(
                controller: durationController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Durasi (Jam)",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              TextFormField(
                controller: priceController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Harga Paket",
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
                final db = await DatabaseService.instance.database;
                await db.insert("packages", {
                  "name": nameController.text,
                  "price": int.parse(priceController.text),
                  "duration_hours": int.parse(durationController.text),
                });
                if (mounted) {
                  Navigator.pop(context);
                  loadData();
                }
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
                // TAB 1: GRID UNIT (RESPONSIF TABLET)
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: units.length,
                  itemBuilder: (context, index) => unitCard(units[index]),
                ),
                // TAB 2: LIST PACKAGE (TITIK 3)
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final pkg = packages[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: const Color(0xff1c273d),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white10),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xffe21388).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.confirmation_number,
                            color: Color(0xffe21388),
                          ),
                        ),
                        title: Text(
                          pkg["name"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${pkg["duration_hours"]} Jam  •  Rp ${pkg["price"]}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white54,
                          ),
                          color: const Color(0xff1c273d),
                          onSelected: (val) {
                            if (val == 'edit')
                              showEditPackageForm(pkg);
                            else if (val == 'delete')
                              deletePackage(pkg["id"]);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.blueAccent,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Edit",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Hapus",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget unitCard(Map unit) {
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
                Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: Text(
                    unit["name"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    unit["type"].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                const Divider(color: Colors.white12, height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rp ${unit["price_per_hour"]}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: unit["status"] == "idle"
                            ? Colors.greenAccent.withOpacity(0.1)
                            : Colors.orangeAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        unit["status"].toString().toUpperCase(),
                        style: TextStyle(
                          color: unit["status"] == "idle"
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white54,
                size: 20,
              ),
              color: const Color(0xff1c273d),
              onSelected: (val) {
                if (val == 'edit')
                  showEditUnitForm(Map<String, dynamic>.from(unit));
                else if (val == 'delete')
                  deleteUnit(unit["id"]);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blueAccent, size: 18),
                      SizedBox(width: 8),
                      Text("Edit", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.redAccent, size: 18),
                      SizedBox(width: 8),
                      Text("Hapus", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
