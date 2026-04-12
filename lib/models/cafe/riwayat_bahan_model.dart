class RiwayatBahanModel {
  final int? id;
  final String? namaBahan;
  final String? kategori;
  final String? satuan;
  final double? jumlah;
  final String? username;
  final String? namaShift;
  final String? waktu;

  RiwayatBahanModel({
    this.id,
    this.namaBahan,
    this.kategori,
    this.satuan,
    this.jumlah,
    this.username,
    this.namaShift,
    this.waktu,
  });

  factory RiwayatBahanModel.fromMap(Map<String, dynamic> map) =>
      RiwayatBahanModel(
        id: map['id'],
        namaBahan: map['nama_bahan'],
        kategori: map['kategori'],
        satuan: map['satuan'],
        jumlah: (map['jumlah'] as num?)?.toDouble(),
        username: map['username'],
        namaShift: map['nama_shift'],
        waktu: map['waktu'],
      );
}
