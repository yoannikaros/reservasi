import 'package:flutter/material.dart';
import 'package:reservasi/utils/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Syarat & Ketentuan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Berlaku sejak: 1 Juli 2024',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _sectionTitle('1. Pengantar'),
              const Text(
                'Selamat datang di aplikasi kami. Syarat & Ketentuan ini mengatur penggunaan Anda terhadap aplikasi kami yang beroperasi sepenuhnya secara offline. Dengan menginstal dan menggunakan aplikasi ini, Anda setuju untuk terikat pada syarat-syarat yang tercantum di bawah ini.',
              ),
              const SizedBox(height: 16),
              _sectionTitle('2. Sifat Aplikasi Offline'),
              const Text(
                'Aplikasi ini dirancang untuk berfungsi 100% secara offline. Tidak ada fitur dalam aplikasi ini yang memerlukan koneksi internet untuk dapat digunakan. Semua data yang Anda buat dan kelola disimpan secara eksklusif di penyimpanan lokal perangkat Anda.',
              ),
              const SizedBox(height: 16),
              _sectionTitle('3. Penyimpanan dan Keamanan Data'),
              const Text(
                'Semua data, termasuk namun tidak terbatas pada informasi reservasi, pelanggan, dan transaksi, disimpan secara lokal di perangkat Anda. Kami tidak mengumpulkan, menyimpan, atau mentransmisikan data pribadi Anda ke server mana pun. Anda bertanggung jawab penuh atas keamanan dan pencadangan data Anda. Menghapus instalan aplikasi akan mengakibatkan hilangnya semua data secara permanen.',
              ),
              const SizedBox(height: 16),
              _sectionTitle('4. Pembatasan Tanggung Jawab'),
              const Text(
                'Aplikasi ini disediakan "sebagaimana adanya". Karena sifatnya yang offline dan data yang disimpan secara lokal, kami tidak bertanggung jawab atas kehilangan, kerusakan, atau korupsi data yang mungkin terjadi karena kegagalan perangkat, penghapusan aplikasi, atau faktor lainnya. Kami tidak memberikan jaminan apa pun, baik tersurat maupun tersirat, mengenai keandalan atau ketersediaan aplikasi.',
              ),
              const SizedBox(height: 16),
              _sectionTitle('5. Pembaruan Aplikasi'),
              const Text(
                'Meskipun aplikasi berjalan secara offline, Anda mungkin memerlukan koneksi internet untuk mengunduh pembaruan aplikasi dari Google Play Store. Pembaruan ini bertujuan untuk perbaikan bug, penambahan fitur, atau peningkatan keamanan.',
              ),
              const SizedBox(height: 16),
              _sectionTitle('6. Perubahan Syarat & Ketentuan'),
              const Text(
                'Kami dapat memperbarui Syarat & Ketentuan ini sewaktu-waktu. Perubahan akan diinformasikan melalui aplikasi atau website resmi.',
              ),
              const SizedBox(height: 16),
              _sectionTitle('7. Kontak'),
              const Text(
                'Jika ada pertanyaan terkait Syarat & Ketentuan, silakan hubungi kami melalui halaman Kontak.',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
} 