import 'package:flutter/material.dart';

/// Konfigurasi aplikasi yang terpusat
/// 
/// File ini berisi semua konfigurasi aplikasi yang dapat diubah dengan mudah
/// tanpa perlu mencari di berbagai file. Untuk mengubah nama aplikasi,
/// cukup ubah nilai [appName] di bawah ini.
/// 
/// Contoh penggunaan:
/// ```dart
/// Text(AppConfig.appName) // Menampilkan nama aplikasi
/// ```
class AppConfig {
  // Nama aplikasi yang akan ditampilkan di seluruh aplikasi
  static const String appName = 'Mediacenter Rokan Hilir';
  
  // Versi aplikasi
  static const String appVersion = '1.0.0';
  
  // Deskripsi aplikasi
  static const String appDescription = 'Aplikasi Berita Lengkap. '
      'Dapatkan informasi terkini dan artikel terbaru dari berbagai kategori.';
  
  // Informasi developer
  static const String developerName = 'Mazadielabs Development Team';
  static const String developerEmail = 'info@aplikasi.go.id';
  
  // URL API base
  static const String baseUrl = 'https://sontiank.com';
  
  // Pengaturan lainnya
  static const int postsPerPage = 10;
  static const int maxCacheSize = 100;
  
  // Warna tema gradient
  static const List<Color> primaryGradient = [
    Color(0xFF8B5CF6), // Ungu indah
    Color(0xFF6366F1), // Indigo
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF11998e), // Hijau teal
    Color(0xFF38ef7d), // Hijau muda
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFfc466b), // Merah pink
    Color(0xFF3f5efb), // Biru
  ];
  
  static const List<Color> backgroundGradient = [
    Color(0xFF8B5CF6), // Ungu indah
    Color(0xFF6366F1), // Indigo
  ];
}
