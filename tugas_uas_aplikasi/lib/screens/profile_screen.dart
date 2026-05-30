import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import 'onboarding_screen.dart';

// Global state for profile
final ValueNotifier<String> globalProfileName = ValueNotifier('Mahasiswa');
final ValueNotifier<String> globalProfileUsername = ValueNotifier('mahasiswa@email.com');
final ValueNotifier<String?> globalProfileImagePath = ValueNotifier(null);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        globalProfileImagePath.value = image.path;
        // Simpan path foto ke SharedPreferences
        await DatabaseHelper.instance.saveProfile(
          name: globalProfileName.value,
          username: globalProfileUsername.value,
          imagePath: image.path,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Foto Profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF2563EB)),
                ),
                title: const Text('Kamera'),
                subtitle: const Text('Ambil foto baru'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: Color(0xFF10B981)),
                ),
                title: const Text('Galeri'),
                subtitle: const Text('Pilih dari galeri foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (globalProfileImagePath.value != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    globalProfileImagePath.value = null;
                    await DatabaseHelper.instance.saveProfile(
                      name: globalProfileName.value,
                      username: globalProfileUsername.value,
                      imagePath: null,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: globalProfileName.value);
    final usernameController = TextEditingController(text: globalProfileUsername.value);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Email / Username',
                  prefixIcon: const Icon(Icons.alternate_email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Username tidak boleh kosong' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Simpan reference sebelum async
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                globalProfileName.value = nameController.text.trim();
                globalProfileUsername.value = usernameController.text.trim();
                // Simpan profil ke SharedPreferences
                await DatabaseHelper.instance.saveProfile(
                  name: nameController.text.trim(),
                  username: usernameController.text.trim(),
                  imagePath: globalProfileImagePath.value,
                );
                nav.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Profil berhasil diperbarui!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.school, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'StudyMate',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Smart Student Planner',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAboutRow(Icons.info_outline, 'Versi', '1.0.0'),
                  const Divider(),
                  _buildAboutRow(Icons.code, 'Platform', 'Flutter (Android & iOS)'),
                  const Divider(),
                  _buildAboutRow(Icons.school_outlined, 'Tujuan', 'Membantu mahasiswa\nmengelola tugas & jadwal kuliah'),
                  const Divider(),
                  _buildAboutRow(Icons.person_outline, 'Pengembang', 'Tim StudyMate'),
                  const SizedBox(height: 8),
                  const Text(
                    '© 2024 StudyMate. All rights reserved.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bantuan & FAQ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _buildFAQItem(
                    '📝 Bagaimana cara menambahkan tugas?',
                    'Buka menu "Tugas" di navigasi bawah, lalu tekan tombol "+" (tambah) di pojok kanan bawah. Isi judul tugas, mata kuliah, deadline, dan prioritas, kemudian simpan.',
                  ),
                  _buildFAQItem(
                    '📅 Bagaimana cara menambahkan jadwal kuliah?',
                    'Buka menu "Jadwal" di navigasi bawah, lalu tekan tombol "+" di pojok kanan bawah. Isi nama mata kuliah, hari, jam mulai, jam selesai, dan ruangan.',
                  ),
                  _buildFAQItem(
                    '🔔 Bagaimana cara melihat deadline mendekati?',
                    'Notifikasi deadline muncul otomatis di ikon lonceng (🔔) yang ada di pojok kanan atas halaman Dashboard. Tugas yang deadline-nya ≤ 2 hari akan muncul di sana.',
                  ),
                  _buildFAQItem(
                    '✅ Bagaimana cara menandai tugas sebagai selesai?',
                    'Di halaman "Tugas", tekan checkbox (kotak centang) di sebelah kiri nama tugas untuk menandai tugas sebagai selesai. Centang lagi untuk membatalkan.',
                  ),
                  _buildFAQItem(
                    '✏️ Bagaimana cara mengubah foto profil?',
                    'Di halaman "Profil", tekan foto profil atau ikon kamera di pojok bawah foto, lalu pilih sumber foto dari Kamera atau Galeri.',
                  ),
                  _buildFAQItem(
                    '👤 Bagaimana cara mengubah nama dan username?',
                    'Di halaman "Profil", tekan tombol "Edit Profil" yang berada di bawah foto profil, lalu ubah nama atau email sesuai keinginanmu.',
                  ),
                  _buildFAQItem(
                    '🗑️ Apa yang terjadi saat keluar sesi?',
                    'Saat menekan "Keluar Sesi", semua data tugas, jadwal, dan profil akan dihapus secara permanen. Aplikasi akan kembali ke halaman awal.',
                  ),
                  _buildFAQItem(
                    '📊 Apa itu halaman Statistik?',
                    'Halaman Statistik menampilkan ringkasan performa belajarmu, termasuk jumlah tugas selesai, belum selesai, dan distribusi berdasarkan mata kuliah.',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.mail_outline, color: Color(0xFF2563EB)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Masih ada pertanyaan?',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Hubungi kami di support@studymate.app',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Keluar Sesi', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Semua data tugas, jadwal, dan profil kamu akan dihapus secara permanen.\n\nApakah kamu yakin ingin keluar?',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _doLogout();
            },
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _doLogout() async {
    // Hapus semua data dari SQLite & SharedPreferences
    await DatabaseHelper.instance.clearAll();

    // Reset global state in-memory
    globalTasks.value = [];
    globalSchedules.value = [];
    globalProfileName.value = 'Mahasiswa';
    globalProfileUsername.value = 'mahasiswa@email.com';
    globalProfileImagePath.value = null;

    // Kembali ke onboarding
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: globalProfileName,
        builder: (context, name, _) {
          return ValueListenableBuilder<String>(
            valueListenable: globalProfileUsername,
            builder: (context, username, _) {
              return ValueListenableBuilder<String?>(
                valueListenable: globalProfileImagePath,
                builder: (context, imagePath, _) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Profile Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar with camera icon
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                GestureDetector(
                                  onTap: _showImagePickerDialog,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 45,
                                      backgroundColor: Colors.white,
                                      backgroundImage: imagePath != null
                                          ? FileImage(File(imagePath))
                                          : null,
                                      child: imagePath == null
                                          ? Icon(Icons.person, size: 50, color: Colors.blue[300])
                                          : null,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _showImagePickerDialog,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              username,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _showEditProfileDialog,
                              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                              label: const Text(
                                'Edit Profil',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Menu Section
                      const Text(
                        'Informasi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildMenuTile(
                              icon: Icons.info_outline,
                              iconBg: const Color(0xFF2563EB),
                              title: 'Tentang Aplikasi',
                              subtitle: 'Versi & info aplikasi',
                              onTap: _showAboutApp,
                            ),
                            Divider(
                              height: 1,
                              indent: 56,
                              color: Colors.grey.shade100,
                            ),
                            _buildMenuTile(
                              icon: Icons.help_outline,
                              iconBg: const Color(0xFF10B981),
                              title: 'Bantuan',
                              subtitle: 'FAQ & panduan penggunaan',
                              onTap: _showHelp,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Logout Button
                      GestureDetector(
                        onTap: _showLogoutConfirmation,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.logout, color: Colors.red, size: 20),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Keluar Sesi',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Hapus semua data dan kembali ke awal',
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.red),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Center(
                        child: Text(
                          'StudyMate v1.0.0',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconBg, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
