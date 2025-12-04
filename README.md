# Mediacenter Flutter APP

Aplikasi berita  yang modern dan responsif dengan fitur lengkap untuk membaca artikel dari berbagai kategori.

## 📱 Fitur Utama

- **Beranda**: Tampilan artikel terbaru dengan desain yang menarik
- **Kategori**: Jelajahi artikel berdasarkan kategori
- **Pencarian**: Cari artikel dengan mudah
- **Favorit**: Simpan artikel favorit untuk dibaca nanti
- **Halaman Statis**: Akses halaman seperti About, Contact, dll
- **Mode Gelap**: Dukungan tema gelap dan terang
- **Offline Reading**: Baca artikel yang sudah di-cache
- **Responsive Design**: Tampilan optimal di berbagai ukuran layar

## 🛠️ Teknologi yang Digunakan

- **Flutter**: Framework utama untuk pengembangan aplikasi
- **Dart**: Bahasa pemrograman
- **HTTP**: Untuk komunikasi dengan API
- **Provider**: State management
- **Shared Preferences**: Penyimpanan lokal
- **SQLite**: Database lokal untuk cache dan favorit

## 🚀 Instalasi dan Setup

### Prasyarat
- Flutter SDK (versi 3.0 atau lebih baru)
- Dart SDK
- Android Studio / VS Code
- Git

### Langkah Instalasi

1. **Clone repository**
   ```bash
   git clone https://github.com/jurnalcode/mediacenterApp
   cd blogger_news_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

## 📁 Struktur Proyek

```
lib/
├── config/
│   └── app_config.dart          # Konfigurasi aplikasi
├── models/
│   ├── category.dart            # Model kategori
│   ├── page_model.dart          # Model halaman
│   └── post.dart                # Model artikel
├── providers/
│   └── app_provider.dart        # State management
├── screens/
│   ├── home_screen.dart         # Layar beranda
│   ├── category_screen.dart     # Layar kategori
│   ├── post_detail_screen.dart  # Detail artikel
│   ├── favorites_screen.dart    # Layar favorit
│   └── ...                     # Layar lainnya
├── services/
│   └── api_service.dart         # Service untuk API
├── utils/
│   └── date_formatter.dart      # Utility untuk format tanggal
├── widgets/
│   ├── custom_app_bar.dart      # Widget app bar kustom
│   ├── shimmer_loading.dart     # Loading animation
│   └── ribbon_accent.dart       # Widget ribbon
└── main.dart                    # Entry point aplikasi
```

## 🔧 Konfigurasi

### API Configuration
Ubah URL API di file `lib/config/app_config.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

### App Configuration
Sesuaikan konfigurasi aplikasi di `lib/config/app_config.dart`:

```dart
static const String appName = 'Nama Aplikasi Anda';
static const String appVersion = '1.0.0';
static const String developerName = 'Nama Developer';
```

## 📱 Build untuk Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Kontribusi

1. Fork repository ini
2. Buat branch fitur baru (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## 📄 Lisensi

Proyek ini dilisensikan di bawah MIT License - lihat file [LICENSE](LICENSE) untuk detail.

## 👥 Tim Pengembang

- **Mazadielabs Development Team**
- Email: mazadiekoko@gmail.com

## 📞 Dukungan

Jika Anda mengalami masalah atau memiliki pertanyaan, silakan:
- Buat issue di GitHub
- Hubungi tim pengembang melalui email
- Kunjungi dokumentasi Flutter: [flutter.dev](https://flutter.dev)

## 🔄 Changelog

### v1.0.0
- Rilis awal aplikasi
- Fitur dasar: beranda, kategori, detail artikel
- Implementasi favorit dan pencarian
- Dukungan mode gelap

---

**Dibuat dengan ❤️ menggunakan Flutter**
