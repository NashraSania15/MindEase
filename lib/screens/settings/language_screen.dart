import 'package:flutter/material.dart';
import '../../services/prefs_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final PrefsService _prefs = PrefsService();
  String _selected = 'en';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final lang = await _prefs.getLanguage();
      if (!mounted) return;
      setState(() {
        _selected = lang;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLanguage(String code) async {
    setState(() => _selected = code);
    try {
      await _prefs.setLanguage(code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            code == 'en' ? 'Language set to English' : 'भाषा हिंदी में सेट की गई',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save language.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

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
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: textColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Language',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Choose your preferred language',
                      style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                    ),

                    const SizedBox(height: 24),

                    _languageTile(
                      title: 'English',
                      subtitle: 'Default language',
                      code: 'en',
                    ),

                    _languageTile(
                      title: 'हिंदी',
                      subtitle: 'Hindi',
                      code: 'hi',
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _languageTile({
    required String title,
    required String subtitle,
    required String code,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final isSelected = _selected == code;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: isSelected
            ? Border.all(color: const Color(0xFF9BE7C4), width: 2)
            : null,
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
      child: ListTile(
        onTap: () => _saveLanguage(code),
        leading: Icon(
          Icons.language,
          color: isSelected ? const Color(0xFF9BE7C4) : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: textColor,
          ),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey)),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF9BE7C4))
            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      ),
    );
  }
}
