import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../diary/diary_screen.dart';
import '../history/history_screen.dart';
import '../emergency/emergency_screen.dart';
import '../settings/settings_screen.dart';
import 'package:mindease/services/biometric_service.dart';
import 'package:mindease/services/prefs_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isAuthenticated = false;

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
    _authenticateUser();
  }

  Future<void> _authenticateUser() async {
    bool enabled = await PrefsService().isBiometricEnabled();

    if (!enabled) {
      setState(() => _isAuthenticated = true);
      return;
    }

    bool unlocked = await BiometricService().authenticate();

    if (!mounted) return;

    if (unlocked) {
      setState(() => _isAuthenticated = true);
    } else {
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    // 🔒 While biometric is not authenticated
    if (!_isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sos),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
