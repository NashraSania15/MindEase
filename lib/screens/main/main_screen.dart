import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../diary/diary_screen.dart';
import '../history/history_screen.dart';
import '../emergency/emergency_screen.dart';
import '../settings/settings_screen.dart';
import '../tour/app_tour_screen.dart';
import '../../services/prefs_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _showTour = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    DiaryScreen(),
    HistoryScreen(),
    EmergencyScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final prefs = PrefsService();
    final tourDone = await prefs.isAppTourDone(user.uid);
    if (!tourDone && mounted) {
      setState(() => _showTour = true);
    }
  }

  Future<void> _onTourDone() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await PrefsService().setAppTourDone(user.uid);
    }
    if (mounted) setState(() => _showTour = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_showTour) {
      return AppTourScreen(onDone: _onTourDone);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFEFF6F5);

    return Scaffold(
      backgroundColor: bgColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_rounded),
              label: 'Diary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sos_rounded),
              label: 'Emergency',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
