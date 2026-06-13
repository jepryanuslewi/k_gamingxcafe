import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../models/cafe/menu_model.dart';

class DropdownMenuWidget extends StatefulWidget {
  final List<MenuModel> items;
  final MenuModel? selectedItem;
  final bool isLoading;
  final Function(MenuModel?) onSelected;
  final Map<int, double>? sisaStokBahan;
  final Map<int, List<Map<String, dynamic>>>? resepCache;
  final Future<void> Function()? onBeforeOpen;

  const DropdownMenuWidget({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.isLoading,
    required this.onSelected,
    this.sisaStokBahan,
    this.resepCache,
    this.onBeforeOpen,
  });

  @override
  State<DropdownMenuWidget> createState() => _DropdownMenuWidgetState();
}

class _DropdownMenuWidgetState extends State<DropdownMenuWidget> {
  Map<int, double> _localSisaStok = {};

  @override
  void initState() {
    super.initState();

    _localSisaStok = Map.from(widget.sisaStokBahan ?? {});
  }

  @override
  void didUpdateWidget(covariant DropdownMenuWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sisaStokBahan != widget.sisaStokBahan) {
      setState(() {
        _localSisaStok = Map.from(widget.sisaStokBahan ?? {});
      });
    }
  }

  int _hitungStokRealtime(MenuModel menu) {
    if (_localSisaStok.isEmpty || widget.resepCache == null) {
      return menu.stok ?? 0;
    }

    final resep = widget.resepCache![menu.id];
    if (resep == null || resep.isEmpty) return menu.stok ?? 0;

    int stokMin = 999999;
    for (var r in resep) {
      final int bahanId = r['bahan_id'] as int;
      final double jumlahPakai = (r['jumlah_pakai'] as num).toDouble();
      final double sisaBahan = _localSisaStok[bahanId] ?? 0;

      if (jumlahPakai <= 0) continue;
      final int bisa = (sisaBahan / jumlahPakai).floor();
      if (bisa < stokMin) stokMin = bisa;
    }

    return stokMin == 999999 ? 0 : stokMin;
  }

  Future<void> _handleBeforeOpen() async {
    if (widget.onBeforeOpen != null) await widget.onBeforeOpen!();

    if (mounted) {
      setState(() {
        _localSisaStok = Map.from(widget.sisaStokBahan ?? {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleBeforeOpen,
      behavior: HitTestBehavior.translucent,
      child: DropdownSearch<MenuModel>(
        items: (filter, loadProps) => widget.items,
        itemAsString: (MenuModel m) => m.nama,
        selectedItem: widget.selectedItem,
        compareFn: (item, selectedItem) => item.id == selectedItem.id,
        onSelected: widget.onSelected,

        dropdownBuilder: (context, selectedItem) {
          return Text(
            selectedItem?.nama ??
                (widget.isLoading ? "Loading..." : "Pilih Menu..."),
            style: const TextStyle(color: Colors.white, fontSize: 14),
          );
        },

        popupProps: PopupProps.menu(
          showSearchBox: true,
          fit: FlexFit.loose,
          constraints: const BoxConstraints(maxHeight: 350),
          listViewProps: const ListViewProps(shrinkWrap: true),
          menuProps: const MenuProps(
            backgroundColor: Color.fromRGBO(11, 18, 32, 1),
          ),
          searchFieldProps: TextFieldProps(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Cari menu...",
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color.fromRGBO(26, 37, 64, 1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          itemBuilder: (context, item, isSelected, isFocused) {
            final int stokRealtime = _hitungStokRealtime(item);
            final bool stokHabis = stokRealtime <= 0;

            return ListTile(
              title: Text(
                item.nama,
                style: TextStyle(
                  color: stokHabis ? Colors.white38 : Colors.white,
                ),
              ),
              subtitle: Text(
                "Harga: Rp ${item.harga.toInt()} | Stok: $stokRealtime",
                style: TextStyle(
                  color: stokHabis ? Colors.redAccent : Colors.white54,
                  fontSize: 11,
                ),
              ),
              trailing: stokHabis
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.redAccent, width: 0.5),
                      ),
                      child: const Text(
                        "HABIS",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Text(
                      item.kategori,
                      style: const TextStyle(
                        color: Color(0xFF00E0C6),
                        fontSize: 10,
                      ),
                    ),
            );
          },
        ),
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromRGBO(26, 37, 64, 1),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white24),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF00E0C6), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
