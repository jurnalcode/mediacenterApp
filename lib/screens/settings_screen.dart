import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/app_provider.dart';
import '../widgets/custom_app_bar.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Bagian Umum
              _buildSectionHeader('General'),
              const SizedBox(height: 8),
              
              // Tombol Mode Gelap
              _buildSettingCard(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Mode gelap untuk melihat dan hemat daya',
                trailing: Switch(
                  value: appProvider.isDarkMode,
                  onChanged: (value) {
                    appProvider.toggleTheme();
                  },
                ),
              ),
              
              // Favorit
              _buildSettingCard(
                icon: Icons.favorite,
                title: 'Favorites',
                subtitle: 'Lihat artikel favorit Anda',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  );
                },
              ),

              _buildSettingCard(
                icon: appProvider.currentUser != null ? Icons.person : Icons.person_add,
                title: appProvider.currentUser != null
                    ? (appProvider.currentUser!.name.isNotEmpty
                        ? appProvider.currentUser!.name
                        : '@${appProvider.currentUser!.username}')
                    : 'Login / Daftar',
                subtitle: appProvider.currentUser != null ? 'Akun aktif' : 'Masuk atau buat akun baru',
                trailing: appProvider.currentUser != null
                    ? const Icon(Icons.logout, size: 16)
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  if (appProvider.currentUser == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  } else {
                    final messenger = ScaffoldMessenger.of(context);
                    await Provider.of<AppProvider>(context, listen: false).logoutUser();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Anda telah keluar')),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              const SizedBox(height: 24),
              
              // Bagian Cache
              _buildSectionHeader('Cache'),
              const SizedBox(height: 8),
              
              // Bersihkan Cache
              _buildSettingCard(
                icon: Icons.cleaning_services,
                title: 'Clear Cache',
                subtitle: 'Hapus cache dan riwayat pencarian',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showClearCacheDialog(context);
                },
              ),
              
              const SizedBox(height: 24),
              
              // Bagian Privasi
              _buildSectionHeader('Privacy'),
              const SizedBox(height: 8),
              
              // Kebijakan Privasi
              _buildSettingCard(
                icon: Icons.privacy_tip,
                title: 'Kebijakan Privasi',
                subtitle: 'Lihat kebijakan privasi, syarat, dan informasi penerbit',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showPrivacyDialog(context);
                },
              ),
              
              const SizedBox(height: 24),
              
              // Bagian Tentang
              _buildSectionHeader('About'),
              const SizedBox(height: 8),
              
              // Tentang Aplikasi
              _buildSettingCard(
                icon: Icons.info,
                title: 'Tentang',
                subtitle: 'Versi build, peringkat',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              
              const SizedBox(height: 32),
              
              // Versi Aplikasi
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua cache dan riwayat pencarian? Ini akan menghapus semua gambar yang diunduh dan data yang disimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Aplikasi ini mengumpulkan dan menggunakan data sesuai dengan kebijakan privasi kami. '
            'Kami berkomitmen untuk melindungi privasi Anda dan memastikan keamanan informasi pribadi Anda.\n\n'
            'Pengumpulan Data:\n'
            '• Kami mungkin mengumpulkan statistik penggunaan untuk meningkatkan aplikasi\n'
            '• Artikel favorit disimpan secara lokal di perangkat Anda\n'
            '• Tidak ada informasi pribadi yang dibagikan kepada pihak ketiga\n\n'
            'Untuk informasi lebih lanjut, silakan kunjungi situs web kami.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: AppConfig.appVersion,
      applicationIcon: const Icon(
        Icons.newspaper,
        size: 48,
        color: Colors.blue,
      ),
      children: [
        Text(
          AppConfig.appDescription,
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• Jelajahi berita berdasarkan kategori\n'
          '• Simpan artikel favorit\n'
          '• Dukungan mode gelap\n'
          '• Membaca secara offline\n'
          '• Fitur pencarian',
        ),
      ],
    );
  }
}
