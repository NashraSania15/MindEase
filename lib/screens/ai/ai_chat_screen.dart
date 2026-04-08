import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../meditation/meditation_screen.dart';
import '../meditation/breathing_meditation_screen.dart';

/// Static response map — maps predefined messages to bot replies.
const Map<String, String> _staticResponses = {
  "😰 I'm anxious":
      "I hear you. Anxiety can feel overwhelming, but you're not alone. 💙\n\n"
      "Try this: Take 3 slow breaths — in for 4 counts, hold for 4, out for 6.\n\n"
      "Would you like me to suggest a grounding exercise?",
  "😴 I'm tired":
      "It's okay to feel tired. Your body might be telling you to slow down. 🌙\n\n"
      "Consider taking a short 15-minute power nap, or try stretching gently.\n\n"
      "Remember: rest is productive too. 💚",
  "🎯 Need motivation":
      "Sometimes motivation starts with one tiny step! 🚀\n\n"
      "Try the '2-minute rule' — just start doing something for 2 minutes. "
      "Once you begin, momentum takes over.\n\n"
      "What's one small thing you could do right now?",
  "😢 I'm sad":
      "I'm sorry you're feeling this way. Sadness is a valid emotion. 💜\n\n"
      "It can help to write about what's making you sad — journaling lets "
      "your feelings flow instead of building up.\n\n"
      "Would you like to talk more about it?",
  "😠 I'm angry":
      "Anger often masks deeper feelings like hurt or frustration. 🔥\n\n"
      "Try counting to 10 slowly, or splash cold water on your face — "
      "it activates your body's calm-down reflex.\n\n"
      "If you want, tell me what triggered this.",
  "🤗 I'm okay":
      "That's wonderful to hear! 🌟\n\n"
      "Keep nurturing your well-being. "
      "Even when you feel okay, small self-care habits make a big difference.\n\n"
      "You're doing great! 💚",
  "😰 Panic attack":
      "I'm here. You're safe. This will pass. 🫂\n\n"
      "Ground yourself: Name 5 things you see, 4 you touch, 3 you hear, "
      "2 you smell, 1 you taste.\n\n"
      "Breathe in for 4 counts, out for 6. Repeat until you feel calmer.",
  "💤 Can't sleep":
      "Trouble sleeping is tough. Here's what might help: 🌙\n\n"
      "• Put your phone away 30 min before bed\n"
      "• Try the 4-7-8 breathing technique\n"
      "• Keep your room cool and dark\n\n"
      "Would you like a guided breathing exercise?",
};

/// Default bot response for free-text messages
const String _defaultResponse =
    "I understand. Thank you for sharing that with me. 🌼\n\n"
    "Would you like to explore some exercises or coping strategies? "
    "You can also try one of the quick options below.";

/// Maps user messages → action buttons to show after the bot reply.
/// Each entry is a list of {label, route} maps.
const Map<String, List<Map<String, String>>> _actionButtons = {
  "😰 I'm anxious": [
    {'label': '🫁 Start Breathing', 'route': 'breathing'},
    {'label': '🧘 Open Meditation', 'route': 'meditation'},
  ],
  "😴 I'm tired": [
    {'label': '🧘 Open Meditation', 'route': 'meditation'},
  ],
  "🎯 Need motivation": [
    {'label': '🧘 Open Meditation', 'route': 'meditation'},
  ],
  "😢 I'm sad": [
    {'label': '🫁 Start Breathing', 'route': 'breathing'},
    {'label': '🧘 Open Meditation', 'route': 'meditation'},
  ],
  "😠 I'm angry": [
    {'label': '🫁 Start Breathing', 'route': 'breathing'},
  ],
  "😰 Panic attack": [
    {'label': '🫁 Start Breathing', 'route': 'breathing'},
    {'label': '🧘 Open Meditation', 'route': 'meditation'},
  ],
  "💤 Can't sleep": [
    {'label': '🫁 Start Breathing', 'route': 'breathing'},
  ],
};

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeCtrl;

  final List<Map<String, dynamic>> messages = [
    {
      'text':
          "Hi there! I'm MindEase, your wellness companion. 💚\n\n"
          "I'm here to listen and help you feel better. "
          "How are you feeling today?",
      'isUser': false,
      'time': _formattedNow(),
    },
  ];

  static String _formattedNow() {
    return DateFormat('h:mm a').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final now = _formattedNow();

    setState(() {
      messages.add({
        'text': text,
        'isUser': true,
        'time': now,
      });
    });

    _controller.clear();
    _scrollToBottom();

    // Simulate typing delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      // Look up static response, fall back to default
      final response = _staticResponses[text] ?? _defaultResponse;

      // Look up action buttons for this user message (default for free-text)
      final actions = _actionButtons[text] ?? const [
        {'label': '🫁 Start Breathing', 'route': 'breathing'},
        {'label': '🧘 Open Meditation', 'route': 'meditation'},
      ];

      setState(() {
        messages.add({
          'text': response,
          'isUser': false,
          'time': _formattedNow(),
          'actions': actions, // null if no actions
        });
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final inputBg = isDark ? const Color(0xFF252540) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                      ),
                    ),
                    child: const Icon(Icons.smart_toy,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MindEase AI',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const Text(
                        '● Always here for you',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Chat messages ──
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  final msg = messages[index];
                  final isUser = msg['isUser'] as bool;
                  final actions = msg['actions'] as List<Map<String, String>>?;
                  return _ChatBubble(
                    text: msg['text'] as String,
                    isUser: isUser,
                    time: msg['time'] as String,
                    isDark: isDark,
                    actions: actions,
                    onActionTap: (route) {
                      if (route == 'breathing') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BreathingMeditationScreen(),
                          ),
                        );
                      } else if (route == 'meditation') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MeditationScreen(),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),

            // ── Quick replies ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _quickReply("😰 I'm anxious", isDark),
                    _quickReply("😴 I'm tired", isDark),
                    _quickReply("🎯 Need motivation", isDark),
                    _quickReply("😢 I'm sad", isDark),
                    _quickReply("😠 I'm angry", isDark),
                    _quickReply("🤗 I'm okay", isDark),
                    _quickReply("😰 Panic attack", isDark),
                    _quickReply("💤 Can't sleep", isDark),
                  ],
                ),
              ),
            ),

            // ── Input ──
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey.shade600 : Colors.grey,
                        ),
                        filled: true,
                        fillColor: inputBg,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 44,
                    width: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => sendMessage(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickReply(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF252540) : Colors.white,
        side: BorderSide(
          color: const Color(0xFF9BE7C4).withOpacity(0.4),
        ),
        onPressed: () => sendMessage(text),
      ),
    );
  }
}

/// Individual chat bubble with optional action buttons.
class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String time;
  final bool isDark;
  final List<Map<String, String>>? actions;
  final void Function(String route)? onActionTap;

  const _ChatBubble({
    required this.text,
    required this.isUser,
    required this.time,
    required this.isDark,
    this.actions,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              gradient: isUser
                  ? const LinearGradient(
                      colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                    )
                  : null,
              color: isUser
                  ? null
                  : (isDark ? const Color(0xFF252540) : Colors.white),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
                height: 1.4,
              ),
            ),
          ),
          // ── Action buttons below bot replies ──
          if (!isUser && actions != null && actions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 2),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: actions!.map((action) {
                  final label = action['label'] ?? '';
                  final route = action['route'] ?? '';
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => onActionTap?.call(route),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF9BE7C4).withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey.shade600 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
