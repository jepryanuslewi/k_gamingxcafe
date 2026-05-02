import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class BackupService {
  static const _dbName = 'rental_ps.db';
  static const _backupFolderName = 'KGamingBackup';

  static Future<File> _getDbFile() async {
    final dbPath = await getDatabasesPath();
    return File(join(dbPath, _dbName));
  }

  static String _generateFileName() {
    final now = DateTime.now();
    final stamp =
        '${now.year}${_pad(now.month)}${_pad(now.day)}_'
        '${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    return 'backup_rental_ps_$stamp.db';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  // ─── Backup ke lokal ───────────────────────────────────────────
  static Future<BackupResult> backupToLocal() async {
    try {
      PermissionStatus status = await Permission.manageExternalStorage
          .request();

      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          return BackupResult.fail('Izin penyimpanan ditolak');
        }
      }

      final dbFile = await _getDbFile();
      if (!await dbFile.exists()) {
        return BackupResult.fail('File database tidak ditemukan');
      }

      final backupDir = Directory(
        '/storage/emulated/0/Download/$_backupFolderName',
      );
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final fileName = _generateFileName();
      final destFile = File(join(backupDir.path, fileName));
      await dbFile.copy(destFile.path);

      return BackupResult.success(
        'Backup berhasil!\n📁 Download/$_backupFolderName/$fileName',
        filePath: destFile.path,
      );
    } catch (e) {
      return BackupResult.fail('Gagal backup: $e');
    }
  }

  // ─── Ambil daftar file backup ──────────────────────────────────
  static Future<List<FileSystemEntity>> getBackupList() async {
    try {
      final backupDir = Directory(
        '/storage/emulated/0/Download/$_backupFolderName',
      );

      if (!await backupDir.exists()) return [];

      final files = await backupDir
          .list()
          .where((f) => f.path.endsWith('.db'))
          .toList();

      files.sort((a, b) => b.path.compareTo(a.path));

      return files;
    } catch (e) {
      debugPrint('Gagal load backup list: $e');
      return [];
    }
  }

  // ─── Restore dari file path (dari list riwayat) ────────────────
  static Future<BackupResult> restoreFromFile(
    String sourcePath, {
    required Future<void> Function() onBeforeRestore, // ✅ support async
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return BackupResult.fail('File backup tidak ditemukan');
      }

      await onBeforeRestore(); // ✅ await

      final dbFile = await _getDbFile();
      await sourceFile.copy(dbFile.path);

      return BackupResult.success(
        'Database berhasil dipulihkan!\nSilakan restart aplikasi.',
      );
    } catch (e) {
      return BackupResult.fail('Gagal restore: $e');
    }
  }

  // ─── Restore dari file picker ──────────────────────────────────
  static Future<BackupResult> restoreFromPicker({
    required Future<void> Function() onBeforeRestore, // ✅ support async
  }) async {
    try {
      PermissionStatus status = await Permission.manageExternalStorage
          .request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          return BackupResult.fail('Izin penyimpanan ditolak');
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        dialogTitle: 'Pilih file backup (.db)',
      );

      if (result == null || result.files.single.path == null) {
        return BackupResult.fail('Tidak ada file yang dipilih');
      }

      final sourcePath = result.files.single.path!;

      if (!sourcePath.endsWith('.db')) {
        return BackupResult.fail('File harus berekstensi .db');
      }

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return BackupResult.fail('File tidak ditemukan');
      }

      await onBeforeRestore(); // ✅ await

      final dbFile = await _getDbFile();
      await sourceFile.copy(dbFile.path);

      return BackupResult.success(
        'Database berhasil dipulihkan!\nSilakan restart aplikasi.',
      );
    } catch (e) {
      return BackupResult.fail('Gagal restore: $e');
    }
  }
}

class BackupResult {
  final bool isSuccess;
  final String message;
  final String? filePath;

  BackupResult._({
    required this.isSuccess,
    required this.message,
    this.filePath,
  });

  factory BackupResult.success(String message, {String? filePath}) =>
      BackupResult._(isSuccess: true, message: message, filePath: filePath);

  factory BackupResult.fail(String message) =>
      BackupResult._(isSuccess: false, message: message);
}
