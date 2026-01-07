import 'package:flutter/material.dart';

class TextAnalysisScreen extends StatefulWidget {
  const TextAnalysisScreen({super.key});

  @override
  State<TextAnalysisScreen> createState() => _TextAnalysisScreenState();
}

class _TextAnalysisScreenState extends State<TextAnalysisScreen> {
  final TextEditingController _controller = TextEditingController();
  bool showResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F7F6), Color(0xFFF1FBFA)],
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
                      'Text Stress Check',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  'Type freely. This will analyze stress — not save automatically.',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // Text Input Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "What’s on your mind right now?",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller,
                        maxLines: 6,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Start typing...',
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_controller.text.length} characters',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            _controller.text.length >= 10
                                ? 'Ready to analyze'
                                : 'Min 10 characters',
                            style: TextStyle(
                              color: _controller.text.length >= 10
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Analyze Button
                _primaryButton(
                  text: 'Analyze Text',
                  enabled: _controller.text.length >= 10,
                  onTap: () {
                    if (_controller.text.length >= 10) {
                      setState(() {
                        showResult = true;
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Result Section
                if (showResult) _resultSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- RESULT UI ----------

  Widget _resultSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🧠 Stress Analysis Result',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              const Text('Detected Signals'),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: const [
                  _Chip('😟 Stress'),
                  _Chip('😰 Anxiety'),
                  _Chip('🧠 Mental Load'),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Stress Level'),
                  Text('72%'),
                ],
              ),

              const SizedBox(height: 6),

              LinearProgressIndicator(
                value: 0.72,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                color: Colors.orange,
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Your words suggest elevated mental stress and worry. '
                      'A short breathing exercise or meditation could help calm your mind.',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _secondaryButton(
                'Try Again',
                onTap: () {
                  setState(() {
                    showResult = false;
                    _controller.clear();
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _primaryButton(
                text: 'Save to Diary',
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- COMPONENTS ----------

  Widget _primaryButton({
    required String text,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: enabled
              ? const LinearGradient(
            colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
          )
              : null,
          color: enabled ? null : Colors.grey.shade300,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
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

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      backgroundColor: const Color(0xFFF1F1F1),
    );
  }
}
