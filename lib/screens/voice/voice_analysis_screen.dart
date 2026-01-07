import 'package:flutter/material.dart';

class VoiceAnalysisScreen extends StatefulWidget {
  const VoiceAnalysisScreen({super.key});

  @override
  State<VoiceAnalysisScreen> createState() => _VoiceAnalysisScreenState();
}

class _VoiceAnalysisScreenState extends State<VoiceAnalysisScreen> {
  int step = 0; // 0-idle, 1-recording, 2-result
  int seconds = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE5F0), Color(0xFFFFF1F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Voice Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _instruction(),

                const SizedBox(height: 40),

                if (step == 0) _idleMic(),
                if (step == 1) _recordingMic(),
                if (step == 2) _resultUI(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI STATES ----------

  Widget _instruction() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'Speak freely for 10–15 seconds',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _idleMic() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              step = 1;
            });
          },
          child: _micCircle(
            color1: Color(0xFF9BE7C4),
            color2: Color(0xFF7AD7C1),
            icon: Icons.mic,
          ),
        ),
        const SizedBox(height: 14),
        const Text('Tap to start recording'),
      ],
    );
  }

  Widget _recordingMic() {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Fake wave
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            12,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 20.0 + (index % 5) * 6,
              width: 4,
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        GestureDetector(
          onTap: () {
            setState(() {
              step = 2;
            });
          },
          child: _micCircle(
            color1: Colors.redAccent,
            color2: Colors.red,
            icon: Icons.mic,
          ),
        ),

        const SizedBox(height: 14),
        Text('$seconds s'),
        const Text('Recording...'),
      ],
    );
  }

  Widget _resultUI() {
    return Column(
      children: [
        // Result card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: const [
                  Text('😔', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sad',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('Detected Mood'),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Stress Level'),
                  Text('68%'),
                ],
              ),

              const SizedBox(height: 6),

              LinearProgressIndicator(
                value: 0.68,
                backgroundColor: Colors.grey.shade300,
                color: Colors.orange,
                minHeight: 8,
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'You sound tired today. Your voice shows signs of fatigue '
                      'and lower energy.',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Suggestions
        _suggestion('🚶', 'Take a 10-minute walk'),
        _suggestion('💧', 'Drink a glass of water'),
        _suggestion('🫁', 'Practice deep breathing'),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _secondaryButton(
                'Try Again',
                onTap: () {
                  setState(() {
                    step = 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _primaryButton('Save Result'),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- COMPONENTS ----------

  Widget _micCircle({
    required Color color1,
    required Color color2,
    required IconData icon,
  }) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [color1, color2]),
      ),
      child: Icon(icon, size: 48, color: Colors.white),
    );
  }

  Widget _suggestion(String emoji, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  Widget _primaryButton(String text) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
