import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Account fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Learning & Notifications
  bool _dailyReminder = false;
  String _learningTarget = '15 menit';

  // Preferences
  bool _darkMode = true;
  bool _soundEffects = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d0721),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine max width based on screen size
          final maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
          
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth > 600 ? 32.0 : 16.0,
                  vertical: 24.0,
                ),
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),
                  
                  // Account Card
                  _buildAccountCard(),
                  const SizedBox(height: 16),
                  
                  // Learning & Notifications Card
                  _buildLearningCard(),
                  const SizedBox(height: 16),
                  
                  // Preferences Card
                  _buildPreferencesCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Color(0xffc084fc)),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xff1e1a3d),
                padding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Pengaturan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Kelola akun dan preferensi belajar Anda',
          style: TextStyle(
            color: Color(0xffa8a4b5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard() {
    return Card(
      color: const Color(0xff1e1a3d),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xff2d2640), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xffa855f7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xffc084fc),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Akun Saya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Name Field
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nama',
                labelStyle: const TextStyle(color: Color(0xffa8a4b5)),
                hintText: 'Masukkan nama Anda',
                hintStyle: const TextStyle(color: Color(0xff6b667a)),
                filled: true,
                fillColor: const Color(0xff0d0721),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xff2d2640)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xff2d2640)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffa855f7), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Color(0xffa8a4b5)),
                hintText: 'Masukkan email Anda',
                hintStyle: const TextStyle(color: Color(0xff6b667a)),
                filled: true,
                fillColor: const Color(0xff0d0721),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xff2d2640)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xff2d2640)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xffa855f7), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data berhasil disimpan'),
                      backgroundColor: Color(0xffa855f7),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffa855f7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningCard() {
    return Card(
      color: const Color(0xff1e1a3d),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xff2d2640), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xffa855f7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Color(0xffc084fc),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Belajar & Notifikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Daily Reminder Switch
            SwitchListTile(
              value: _dailyReminder,
              onChanged: (value) {
                setState(() {
                  _dailyReminder = value;
                });
              },
              title: const Text(
                'Pengingat Harian',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Terima pengingat belajar setiap hari',
                style: TextStyle(
                  color: Color(0xffa8a4b5),
                  fontSize: 13,
                ),
              ),
              activeThumbColor: const Color(0xffa855f7),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(color: Color(0xff2d2640)),
            
            // Learning Target Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Target Waktu Belajar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _learningTarget,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xff0d0721),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff2d2640)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xff2d2640)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xffa855f7), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  dropdownColor: const Color(0xff1e1a3d),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(
                      value: '5 menit',
                      child: Text('5 menit'),
                    ),
                    DropdownMenuItem(
                      value: '15 menit',
                      child: Text('15 menit'),
                    ),
                    DropdownMenuItem(
                      value: '30 menit',
                      child: Text('30 menit'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _learningTarget = value ?? '15 menit';
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Card(
      color: const Color(0xff1e1a3d),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xff2d2640), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xffa855f7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Color(0xffc084fc),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Preferensi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Dark Mode Switch
            SwitchListTile(
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
              title: const Text(
                'Mode Gelap',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Gunakan tema gelap untuk aplikasi',
                style: TextStyle(
                  color: Color(0xffa8a4b5),
                  fontSize: 13,
                ),
              ),
              activeThumbColor: const Color(0xffa855f7),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(color: Color(0xff2d2640)),
            
            // Sound Effects Switch
            SwitchListTile(
              value: _soundEffects,
              onChanged: (value) {
                setState(() {
                  _soundEffects = value;
                });
              },
              title: const Text(
                'Efek Suara',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Mainkan efek suara saat belajar',
                style: TextStyle(
                  color: Color(0xffa8a4b5),
                  fontSize: 13,
                ),
              ),
              activeThumbColor: const Color(0xffa855f7),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
