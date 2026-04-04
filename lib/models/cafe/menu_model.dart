class MenuModel {
  final int? id;
  final String nama;
  final double harga;
  final String kategori;
  final int? stok; // Tambahkan ini agar sinkron dengan DB

  MenuModel({
    this.id,
    required this.nama,
    required this.harga,
    required this.kategori,
    this.stok = 0, // Default 0
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // Bagus untuk auto-increment
      'nama': nama,
      'harga': harga,
      'kategori': kategori,
      'stok': stok ?? 0, // Pastikan dikirim ke DB
    };
  }

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
      id: map['id'],
      nama: map['nama'] ?? '',
      // Konversi harga dari INTEGER DB ke double Dart secara aman
      harga: (map['harga'] as num?)?.toDouble() ?? 0.0,
      kategori: map['kategori'] ?? '',
      stok: map['stok'] ?? 0,
    );
  }
}
