import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindease/models/user_model.dart';
import 'package:mindease/services/auth_service.dart';
import 'package:mindease/services/stress_history_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/stress_entry.dart';
import 'package:mindease/screens/profile/reports_screen.dart';
import 'change_password_screen.dart';
import 'package:mindease/screens/main/main_screen.dart';

typedef DashboardScreen = MainScreen;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;
  String _stressValue = '—';
  String _entriesCount = '0';
  File? _profileImage;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStats();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        setState(() => _profileImage = file);
      }
    }
  }

  Future<void> _pickImage() async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() => _profileImage = file);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', pickedFile.path);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }
    final user = await AuthService().getUserData(uid);
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStats() async {
    // Counts are now handled by StreamBuilder for reactive updates
    // but we can initialize defaults here if needed.
    setState(() {
      final latest = StressHistoryService.getLatestCombined();
      _stressValue = latest > 0 ? '${latest.toStringAsFixed(0)}%' : 'No data';
    });
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _user?.name ?? '');
    final emailController = TextEditingController(text: _user?.email ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email (Optional)'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, {
              'name': nameController.text.trim(),
              'email': emailController.text.trim()
            }),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result['name']!.isEmpty) return;
    
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);

    try {
      await AuthService().updateUserName(result['name']!);
      
      // Update local UI state without deep reload
      if (mounted) {
        if (_user != null) {
          setState(() {
            _user = UserModel(
              uid: _user!.uid,
              email: result['email']!.isNotEmpty ? result['email']! : _user!.email,
              name: result['name']!,
              createdAt: _user!.createdAt,
            );
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFEFF6F5),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF0D0D1A), Color(0xFF1A1A2E)]
                : const [Color(0xFFF7F7FB), Color(0xFFEFF6F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Back
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: textColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Avatar
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                                ),
                                image: _profileImage != null
                                    ? DecorationImage(
                                        image: FileImage(_profileImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF9BE7C4).withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: _profileImage == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Color(0xFF7AD7C1),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Name (real)
                      Text(
                        _user?.name ?? FirebaseAuth.instance.currentUser?.displayName ?? '—',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Email (real)
                      Text(
                        _user?.email ?? FirebaseAuth.instance.currentUser?.email ?? '—',
                        style: TextStyle(color: subtextColor),
                      ),

                      const SizedBox(height: 20),

                      // Stress summary (dynamic) - Reactive (Part 1)
                      StreamBuilder<List<StressEntry>>(
                        stream: StressHistoryService.dailyStream,
                        builder: (context, dailySnapshot) {
                          return StreamBuilder<List<WeeklyEntry>>(
                            stream: StressHistoryService.weeklyStream,
                            builder: (context, weeklySnapshot) {
                              final dailyCount = dailySnapshot.data?.length ?? 0;
                              final weeklyCount = weeklySnapshot.data?.fold<int>(0, (sum, w) => sum + w.entries.length) ?? 0;
                              final totalEntries = dailyCount + weeklyCount;
                              
                              final latestStress = dailyCount > 0 
                                  ? dailySnapshot.data!.last.combinedStress 
                                  : 0.0;
                              
                              final stressStr = latestStress > 0 
                                  ? '${latestStress.toStringAsFixed(0)}%' 
                                  : 'No data';

                              String bestEmoji = '😊';
                              if (latestStress >= 80) bestEmoji = '😨';
                              else if (latestStress >= 60) bestEmoji = '😟';
                              else if (latestStress >= 30) bestEmoji = '😐';

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF9BE7C4).withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: isDark
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: const Color(0xFF9BE7C4).withOpacity(0.12),
                                            blurRadius: 14,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _ProfileStat(
                                      title: 'Latest Stress',
                                      value: stressStr,
                                      icon: Icons.monitor_heart,
                                    ),
                                    _ProfileStat(
                                      title: 'State',
                                      value: bestEmoji,
                                      icon: Icons.emoji_emotions,
                                    ),
                                    _ProfileStat(
                                      title: 'Total Checks',
                                      value: totalEntries.toString(),
                                      icon: Icons.assignment_turned_in,
                                    ),
                                  ],
                                ),
                              );
                            }
                          );
                        }
                      ),

                      const SizedBox(height: 24),

                      // My Reports Button
                      _infoTile(
                        icon: Icons.assignment_outlined,
                        title: 'My Reports',
                        value: 'View All',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReportsScreen()),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Personal info (real data)
                      _infoTile(
                        icon: Icons.person_outline,
                        title: 'Name',
                        value: _user?.name ?? '—',
                      ),
                      _infoTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: _user?.email ?? '—',
                      ),
                      _infoTile(
                        icon: Icons.lock_outline,
                        title: 'Password',
                        value: '••••••••',
                        onTap: () {
                          if (_isActionLoading) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Edit profile button
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                          ),
                        ),
                        child: TextButton(
                          onPressed: _isActionLoading ? null : _showEditProfileDialog,
                          child: _isActionLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(color: subtextColor),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: subtextColor),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ProfileStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
