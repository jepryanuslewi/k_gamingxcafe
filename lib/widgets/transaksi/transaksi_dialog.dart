import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k_gamingxcafe/models/cafe/menu_model.dart';
import 'package:k_gamingxcafe/providers/cafe/menu_provider.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import 'package:k_gamingxcafe/widgets/transaksi/dropdown_menu_widget.dart';
import 'package:provider/provider.dart';

class TransactionDialog {
  static void show(BuildContext context, {required String shiftName}) {
    List<Map<String, dynamic>> items = [
      {'selectedProduk': null, 'qty': 0},
    ];
    String? errorMessage;

    Map<int, List<Map<String, dynamic>>> resepCache = {};
    Map<int, double> stokBahanAwal = {};
    bool stokSudahDimuat = false;
    Map<int, double> sisaStokBahanState = {};

    Future<void> muatStokBahan() async {
      if (stokSudahDimuat) return;
      final semuaBahan = await DatabaseService.instance.getBahanSemua();
      for (var b in semuaBahan) {
        stokBahanAwal[b['id'] as int] = (b['stok_saat_ini'] as num).toDouble();
      }
      stokSudahDimuat = true;
    }

    Future<List<Map<String, dynamic>>> getResep(int productId) async {
      if (resepCache.containsKey(productId)) return resepCache[productId]!;
      final resep = await DatabaseService.instance.getResepByProductId(
        productId,
      );
      resepCache[productId] = resep;
      return resep;
    }

    Future<Map<int, double>> hitungSisaStokBahan(
      List<Map<String, dynamic>> currentItems,
    ) async {
      await muatStokBahan();

      final Map<int, double> sisa = Map.from(stokBahanAwal);

      for (var item in currentItems) {
        final MenuModel? p = item['selectedProduk'];
        final int qty = item['qty'] as int;
        if (p == null || qty <= 0 || p.id == null) continue;

        final resep = await getResep(p.id!);
        for (var r in resep) {
          final int bahanId = r['bahan_id'] as int;
          final double jumlahPakai = (r['jumlah_pakai'] as num).toDouble();
          sisa[bahanId] = (sisa[bahanId] ?? 0) - (jumlahPakai * qty);
        }
      }

      return sisa;
    }

    Future<String?> bisaTambahQty(
      List<Map<String, dynamic>> currentItems,
      int targetIndex,
      int newQty,
    ) async {
      await muatStokBahan();

      final MenuModel? p = currentItems[targetIndex]['selectedProduk'];
      if (p == null || p.id == null) return null;

      final resep = await getResep(p.id!);
      if (resep.isEmpty) return null;

      final Map<int, double> sisaTanpaItem = Map.from(stokBahanAwal);
      for (int i = 0; i < currentItems.length; i++) {
        if (i == targetIndex) continue; // skip item ini
        final MenuModel? pi = currentItems[i]['selectedProduk'];
        final int qi = currentItems[i]['qty'] as int;
        if (pi == null || qi <= 0 || pi.id == null) continue;

        final resepI = await getResep(pi.id!);
        for (var r in resepI) {
          final int bahanId = r['bahan_id'] as int;
          final double jumlahPakai = (r['jumlah_pakai'] as num).toDouble();
          sisaTanpaItem[bahanId] =
              (sisaTanpaItem[bahanId] ?? 0) - (jumlahPakai * qi);
        }
      }

      for (var r in resep) {
        final int bahanId = r['bahan_id'] as int;
        final double jumlahPakai = (r['jumlah_pakai'] as num).toDouble();
        final double sisaUntukItem = sisaTanpaItem[bahanId] ?? 0;
        final double dibutuhkan = jumlahPakai * newQty;

        if (dibutuhkan > sisaUntukItem) {
          final semuaBahan = await DatabaseService.instance.getBahanSemua();
          final bahan = semuaBahan.firstWhere(
            (b) => b['id'] == bahanId,
            orElse: () => {'nama': 'Bahan', 'satuan': ''},
          );
          final maxBisa = (sisaUntukItem / jumlahPakai).floor();
          return "Bahan '${bahan['nama']}' tidak cukup!\n"
              "Maks qty ${p.nama}: $maxBisa";
        }
      }

      return null;
    }

    Future<void> updateSisaStok(StateSetter setState) async {
      final sisa = await hitungSisaStokBahan(items);
      setState(() => sisaStokBahanState = sisa);
    }

    context.read<MenuProvider>().fetchMenu().then((_) async {
      await muatStokBahan();

      final menuProv = context.read<MenuProvider>();
      for (var menu in menuProv.listMenu) {
        if (menu.id != null) {
          await getResep(menu.id!);
        }
      }

      debugPrint('Preload selesai. resepCache: ${resepCache.keys.toList()}');
      debugPrint('stokBahanAwal: $stokBahanAwal');
    });
    context.read<MenuProvider>().fetchMenu();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final menuProv = context.watch<MenuProvider>();
            Map<int, double> _hitungSisaSync() {
              final Map<int, double> sisa = Map.from(stokBahanAwal);
              for (var item in items) {
                final MenuModel? p = item['selectedProduk'];
                final int qty = item['qty'] as int;
                if (p == null || qty <= 0 || p.id == null) continue;

                final resep = resepCache[p.id!];
                if (resep == null) continue;

                for (var r in resep) {
                  final int bahanId = r['bahan_id'] as int;
                  final double jumlahPakai = (r['jumlah_pakai'] as num)
                      .toDouble();
                  sisa[bahanId] = (sisa[bahanId] ?? 0) - (jumlahPakai * qty);
                }
              }
              return sisa;
            }

            sisaStokBahanState = _hitungSisaSync();
            return AlertDialog(
              backgroundColor: const Color.fromRGBO(11, 18, 32, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Colors.white10),
              ),
              contentPadding: const EdgeInsets.all(20),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/bgLoginScreen.png", height: 60),
                    const SizedBox(height: 10),
                    const Text(
                      "TRANSAKSI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 20),

                    if (errorMessage != null)
                      Container(
                        width: 500,
                        padding: const EdgeInsets.all(2),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          alignment: WrapAlignment.center,
                          children: items.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;

                            return KeyedSubtree(
                              key: ValueKey("item_$index"),
                              child: _buildProductCard(
                                context: context,
                                produk: item['selectedProduk'],
                                qty: item['qty'],
                                menuList: menuProv.listMenu,
                                isLoading: menuProv.isLoading,
                                onProdukChanged: (val) async {
                                  final MenuModel? menu = val as MenuModel?;
                                  if (menu == null) {
                                    setState(() {
                                      items[index]['selectedProduk'] = null;
                                      items[index]['qty'] = 0;
                                      errorMessage = null;
                                    });
                                    return;
                                  }

                                  if (menu.id != null) await getResep(menu.id!);

                                  final tempItems =
                                      List<Map<String, dynamic>>.from(items);
                                  tempItems[index] = {
                                    'selectedProduk': menu,
                                    'qty': 1,
                                  };
                                  final error = await bisaTambahQty(
                                    tempItems,
                                    index,
                                    1,
                                  );

                                  if (error != null) {
                                    setState(
                                      () => errorMessage =
                                          "${menu.nama}: Stok bahan tidak mencukupi!",
                                    );
                                    return;
                                  }

                                  setState(() {
                                    items[index]['selectedProduk'] = menu;
                                    items[index]['qty'] = 0;
                                    errorMessage = null;
                                  });
                                },
                                onQtyChanged: (newQty) async {
                                  if (newQty < 0) return;

                                  if (newQty == 0) {
                                    setState(() {
                                      items[index]['qty'] = 0;
                                      errorMessage = null;
                                    });
                                    return;
                                  }

                                  final error = await bisaTambahQty(
                                    items,
                                    index,
                                    newQty,
                                  );
                                  if (error != null) {
                                    setState(() => errorMessage = error);
                                    return;
                                  }

                                  setState(() {
                                    items[index]['qty'] = newQty;
                                    errorMessage = null;
                                  });
                                },
                                onRemove: () {
                                  if (items.length > 1) {
                                    setState(() {
                                      items.removeAt(index);
                                      errorMessage = null;
                                    });
                                  }
                                  updateSisaStok(setState);
                                },
                                sisaStokBahan: sisaStokBahanState,
                                resepCache: resepCache,
                                onBeforeOpen: () => updateSisaStok(setState),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    InkWell(
                      onTap: () async {
                        setState(() {
                          items.add({'selectedProduk': null, 'qty': 0});
                          errorMessage = null;
                        });
                        _hitungSisaSync();
                        await updateSisaStok(setState);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Color(0xFF00E0C6),
                          size: 30,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(flex: 3, child: _buildTotalInput(items)),
                        const SizedBox(width: 15),
                        _buildButton(
                          label: "BATAL",
                          color: const Color(0xFFD81B72),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        _buildButton(
                          label: "SIMPAN",
                          color: const Color(0xFF00E0C6),
                          textColor: const Color.fromRGBO(11, 18, 32, 1),
                          onPressed: () async {
                            final validItems = items
                                .where(
                                  (i) =>
                                      i['selectedProduk'] != null &&
                                      i['qty'] > 0,
                                )
                                .toList();

                            if (validItems.isEmpty) {
                              setState(
                                () =>
                                    errorMessage = "Pilih produk dan isi qty!",
                              );
                              return;
                            }

                            final sisaStok = await hitungSisaStokBahan(
                              validItems,
                            );
                            for (var entry in sisaStok.entries) {
                              if (entry.value < 0) {
                                final semuaBahan = await DatabaseService
                                    .instance
                                    .getBahanSemua();
                                final bahan = semuaBahan.firstWhere(
                                  (b) => b['id'] == entry.key,
                                  orElse: () => {'nama': 'Bahan'},
                                );
                                setState(
                                  () => errorMessage =
                                      "Bahan '${bahan['nama']}' tidak mencukupi!",
                                );
                                return;
                              }
                            }

                            num totalAkhir = validItems.fold<num>(0, (
                              sum,
                              item,
                            ) {
                              final MenuModel? p = item['selectedProduk'];
                              return sum +
                                  ((p?.harga ?? 0) * (item['qty'] as int));
                            });

                            if (totalAkhir <= 0) return;

                            bool sukses = await context
                                .read<MenuProvider>()
                                .simpanTransaksi(
                                  validItems,
                                  totalAkhir,
                                  shiftName,
                                );

                            if (sukses && context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFF00E0C6),
                                  content: Center(
                                    child: Text(
                                      'Transaksi berhasil disimpan!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ],
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

  static Widget _buildProductCard({
    required BuildContext context,
    required dynamic produk,
    required int qty,
    required List<MenuModel> menuList,
    required bool isLoading,
    required Function(dynamic) onProdukChanged,
    required Function(int) onQtyChanged,
    required VoidCallback onRemove,
    Map<int, double>? sisaStokBahan,
    Map<int, List<Map<String, dynamic>>>? resepCache,
    Future<void> Function()? onBeforeOpen,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(20, 28, 47, 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.fastfood, color: Colors.white38, size: 18),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownMenuWidget(
            items: menuList,
            selectedItem: produk,
            isLoading: isLoading,
            onSelected: onProdukChanged,
            sisaStokBahan: sisaStokBahan,
            resepCache: resepCache,
            onBeforeOpen: onBeforeOpen,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Color(0xFF00E0C6),
                ),
                onPressed: () => onQtyChanged(qty - 1),
              ),
              Text(
                "$qty",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF00E0C6),
                ),
                onPressed: () => onQtyChanged(qty + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildTotalInput(List<Map<String, dynamic>> items) {
    num total = items.fold<num>(0, (sum, item) {
      final MenuModel? p = item['selectedProduk'];
      final int q = item['qty'] as int;
      return sum + ((p?.harga ?? 0) * q);
    });

    return TextField(
      readOnly: true,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: "Total: Rp ${NumberFormat("#,###", "id_ID").format(total)}",
        hintStyle: const TextStyle(color: Color(0xFF00E0C6), fontSize: 16),
        filled: true,
        fillColor: const Color.fromRGBO(20, 28, 47, 1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      ),
    );
  }

  static Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    Color textColor = Colors.white,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
