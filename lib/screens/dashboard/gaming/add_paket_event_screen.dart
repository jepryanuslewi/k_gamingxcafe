import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class AddPaketEventScreen extends StatefulWidget {
  const AddPaketEventScreen({super.key});

  @override
  State<AddPaketEventScreen> createState() => _AddPaketEventScreenState();
}

class _AddPaketEventScreenState extends State<AddPaketEventScreen> {
  List<Map<String, dynamic>> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPackages();
  }

  Future<void> loadPackages() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final db = await DatabaseService.instance.database;
    final data = await db.query("packages", orderBy: "price ASC");

    if (mounted) {
      setState(() {
        packages = data;
        isLoading = false;
      });
    }
  }

  Future<void> deletePackage(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete("packages", where: "id = ?", whereArgs: [id]);
    loadPackages();
  }

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
                  loadPackages();
                }
              }
            },
            child: const Text("Update"),
          ),
        ],
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
                if (mounted) {
                  Navigator.pop(context);
                  loadPackages();
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
        title: const Text("Paket Event", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffe21388),
        onPressed: showAddPackageForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                    leading: const Icon(
                      Icons.confirmation_number,
                      color: Color(0xffe21388),
                    ),
                    title: Text(
                      pkg["name"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${pkg["duration_hours"]} Jam • Rp ${pkg["price"]}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: PopupMenuButton<String>(
                      color: const Color(0xff1c273d),
                      onSelected: (val) {
                        if (val == 'edit')
                          showEditPackageForm(pkg);
                        else if (val == 'delete')
                          deletePackage(pkg["id"]);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            "Edit",
                            style: TextStyle(color: Colors.greenAccent),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            "Hapus",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
