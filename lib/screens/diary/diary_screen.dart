import 'package:flutter/material.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  int selectedMood = 0; // 0-happy,1-neutral,2-sad,3-stressed
  int tabIndex = 0; // 0-write, 1-history

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: const [
                    Icon(Icons.arrow_back_ios, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'My Private Diary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '🔒 Encrypted & Only You Can Access',
                  style: TextStyle(color: Colors.green, fontSize: 13),
                ),

                const SizedBox(height: 20),

                // Toggle
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      _toggleButton('Write Entry', 0),
                      _toggleButton('Diary History', 1),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Date
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Wednesday, January 7, 2026',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Text('How are you feeling today?'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Mood selector
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _mood('😊', 'Happy', 0),
                      _mood('😐', 'Neutral', 1),
                      _mood('😔', 'Sad', 2),
                      _mood('😣', 'Stressed', 3),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Diary text area
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const TextField(
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText:
                      'Write freely… no one is judging you.\n'
                          'This is your safe space to express your thoughts, '
                          'feelings, and experiences.',
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Voice & Photo
                Row(
                  children: const [
                    Icon(Icons.mic),
                    SizedBox(width: 6),
                    Text('Voice Note'),
                    Spacer(),
                    Icon(Icons.photo),
                    SizedBox(width: 6),
                    Text('Photo'),
                  ],
                ),

                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: _secondaryButton('Close Diary'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _primaryButton('Save Entry'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleButton(String text, int index) {
    final isActive = tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF9BE7C4) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mood(String emoji, String label, int index) {
    final selected = selectedMood == index;
    return GestureDetector(
      onTap: () => setState(() => selectedMood = index),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: selected ? 28 : 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton(String text) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _secondaryButton(String text) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: Center(
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
