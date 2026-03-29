import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/prefs_service.dart';
import '../../services/diary_service.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final PrefsService _prefs = PrefsService();
  final DiaryService _diary = DiaryService();

  bool _appLockEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final lockEnabled = await _prefs.isAppLockEnabled();
      if (!mounted) return;
      setState(() {
        _appLockEnabled = lockEnabled;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAppLock(bool value) async {
    try {
      if (value) {
        // Check if PIN is set; if not, prompt user to set one
        final hasPin = await _diary.hasPinSet();
        if (!hasPin) {
          if (!mounted) return;
          final pin = await _showSetPinDialog();
          if (pin == null || pin.length != 4) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please set a 4-digit PIN to enable App Lock.')),
            );
            return;
          }
          await _diary.setPin(pin);
        }
      }

      await _prefs.setAppLockEnabled(value);
      if (!mounted) return;
      setState(() => _appLockEnabled = value);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'App Lock enabled' : 'App Lock disabled'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update App Lock setting.')),
      );
    }
  }

  Future<String?> _showSetPinDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Set a 4-digit PIN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter 4-digit PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermission(Permission permission, String name) async {
    try {
      final status = await permission.request();
      if (!mounted) return;

      String message;
      if (status.isGranted) {
        message = '$name permission granted';
      } else if (status.isPermanentlyDenied) {
        message = '$name permission denied. Please enable it from device Settings.';
        openAppSettings();
      } else {
        message = '$name permission denied';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to request $name permission.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F7FB), Color(0xFFEFF6F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Privacy & Security',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── App Lock ──
                    _sectionTitle('App Lock'),
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: SwitchListTile(
                        secondary: const Icon(Icons.lock, color: Colors.green),
                        title: const Text('App Lock'),
                        subtitle: const Text('Require PIN to access diary'),
                        value: _appLockEnabled,
                        activeColor: const Color(0xFF9BE7C4),
                        onChanged: _toggleAppLock,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Permissions ──
                    _sectionTitle('Permissions'),
                    _permissionTile(
                      icon: Icons.camera_alt,
                      title: 'Camera',
                      subtitle: 'Face analysis & stress detection',
                      onTap: () => _requestPermission(Permission.camera, 'Camera'),
                    ),
                    _permissionTile(
                      icon: Icons.mic,
                      title: 'Microphone',
                      subtitle: 'Voice analysis & recording',
                      onTap: () => _requestPermission(Permission.microphone, 'Microphone'),
                    ),
                    _permissionTile(
                      icon: Icons.folder,
                      title: 'Storage',
                      subtitle: 'Save audio recordings',
                      onTap: () => _requestPermission(Permission.storage, 'Storage'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget _permissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
