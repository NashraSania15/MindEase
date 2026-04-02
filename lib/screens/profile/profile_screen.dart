import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindease/models/user_model.dart';
import 'package:mindease/services/auth_service.dart';
import 'package:mindease/services/stress_history_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStats();
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Count diary entries
      final entriesSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('diary_entries')
          .get();

      // Compute current latest stress
      String stress = 'No data yet';
      final historySnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('stress_history')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (historySnap.docs.isNotEmpty) {
        final data = historySnap.docs.first.data();
        final stressVal = StressHistoryService.computeStress(data);
        if (stressVal > 0) {
          stress = '${stressVal.toStringAsFixed(0)}%';
        }
      }

      if (!mounted) return;
      setState(() {
        _entriesCount = entriesSnap.docs.length.toString();
        _stressValue = stress;
      });
    } catch (_) {
      // Silently fail — stats stay at defaults
    }
  }

  Future<void> _showEditNameDialog() async {
    final controller = TextEditingController(text: _user?.name ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      await AuthService().updateUserName(result);
      // Reload user data
      await _loadUser();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update name.')),
      );
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
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9BE7C4).withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
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

                      // Stress summary (dynamic)
                      Container(
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
                                title: 'Current Stress',
                                value: _stressValue,
                                icon: Icons.monitor_heart,
                              ),
                            const _ProfileStat(
                              title: 'Best Mood',
                              value: '😊',
                              icon: Icons.emoji_emotions,
                            ),
                            _ProfileStat(
                              title: 'Entries',
                              value: _entriesCount,
                              icon: Icons.book,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

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
                          onPressed: _showEditNameDialog,
                          child: const Text(
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
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
        ],
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
