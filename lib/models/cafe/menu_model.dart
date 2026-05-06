class MenuModel {
  final int? id;
  final String nama;
  final double harga;
  final String kategori;
  final int? stok; 
 

  MenuModel({
    this.id,
    required this.nama,
    required this.harga,
    required this.kategori,
    this.stok,
  });


  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'harga': harga,
      'kategori': kategori,
      'stok': stok ?? 0,
    };
  }

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
      id: map['id'],
      nama: map['nama'] ?? '',
      harga: (map['harga'] as num?)?.toDouble() ?? 0.0,
      kategori: map['kategori'] ?? '',
      stok: map['stok'] ?? 0,
    );
  }
}
