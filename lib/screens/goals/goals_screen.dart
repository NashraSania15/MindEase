import 'package:flutter/material.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<Map<String, dynamic>> goals = [
    {'title': 'Meditate 5 minutes', 'icon': '🧘', 'done': true},
    {'title': 'Drink water', 'icon': '💧', 'done': true},
    {'title': 'Write 1 diary entry', 'icon': '📓', 'done': false},
    {'title': 'Take a short break', 'icon': '☕', 'done': false},
  ];

  void _addGoal(String text, String emoji) {
    if (text.trim().isEmpty) return;
    setState(() {
      goals.add({'title': text, 'icon': emoji, 'done': false});
    });
  }

  void _deleteGoal(int index) {
    setState(() {
      goals.removeAt(index);
    });
  }

  void _clearCompleted() {
    setState(() {
      goals.removeWhere((g) => g['done'] == true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    final completed = goals.where((g) => g['done']).length;
    final progress = goals.isEmpty ? 0.0 : completed / goals.length;

    return Scaffold(
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
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        "Today's Wellness Goals",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (completed > 0)
                      GestureDetector(
                        onTap: () => _showClearCompletedDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A2E2A) : const Color(0xFFEAFBF6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cleaning_services,
                                  size: 16, color: Color(0xFF4CAF50)),
                              SizedBox(width: 4),
                              Text(
                                'Clear done',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🌱'),
                          const SizedBox(width: 6),
                          Text(
                            '$completed of ${goals.length} completed',
                            style: TextStyle(color: subtextColor),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Progress card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Today's Progress"),
                                Text('${(progress * 100).round()}%'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 10,
                                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                color: const Color(0xFF9BE7C4),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Goals list
                      if (goals.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
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
                          child: Column(
                            children: [
                              const Text('🎯',
                                  style: TextStyle(fontSize: 36)),
                              const SizedBox(height: 10),
                              Text(
                                'No goals yet!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap the button below to add your first goal',
                                style: TextStyle(
                                    color: subtextColor, fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                      ...List.generate(goals.length, (index) {
                        return _goalTile(goals[index], index);
                      }),

                      const SizedBox(height: 16),

                      // Add goal button
                      GestureDetector(
                        onTap: () => _showAddGoalSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9BE7C4),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Add New Goal',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Motivation card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A1A) : const Color(0xFFFFE8A3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          '✨ Keep Going!\n\n'
                          'Small habits reduce stress over time. '
                          'You\'re building a healthier, calmer you.',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade300 : Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalTile(Map<String, dynamic> goal, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final isDone = goal['done'] as bool;

    return Dismissible(
      key: ValueKey('goal_${goal['title']}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => _deleteGoal(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDone
              ? (isDark ? const Color(0xFF1A2E2A) : const Color(0xFFEAFBF6))
              : cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  goal['done'] = !isDone;
                });
              },
              child: Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? const Color(0xFF9BE7C4)
                      : Colors.transparent,
                  border: Border.all(
                    color: isDone
                        ? const Color(0xFF9BE7C4)
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Text(goal['icon'] as String,
                style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                goal['title'] as String,
                style: TextStyle(
                  fontSize: 14,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : textColor,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _deleteGoal(index),
              child: const Icon(Icons.close, size: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ── Clear completed dialog ──

  void _showClearCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Completed Goals?'),
        content: const Text(
          'This will remove all completed goals from your list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _clearCompleted();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9BE7C4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Clear',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Add goal bottom sheet ──

  void _showAddGoalSheet(BuildContext context) {
    final controller = TextEditingController();
    String selectedEmoji = '🎯';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final emojis = ['🎯', '🧘', '💧', '📓', '☕', '🏃', '💪', '🍎', '😊', '🌿', '📖', '🎨'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final sheetDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetTextColor = sheetDark ? Colors.white : Colors.black87;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Add New Goal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: sheetTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set a new wellness goal for today',
                    style: TextStyle(color: sheetDark ? Colors.grey.shade400 : Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 20),

                  // Emoji picker
                  Text(
                    'Choose an icon',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: sheetTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: emojis.map((emoji) {
                      final isSelected = emoji == selectedEmoji;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() => selectedEmoji = emoji);
                        },
                        child: Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF9BE7C4).withOpacity(0.3)
                                : (sheetDark ? Colors.grey.shade800 : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF9BE7C4),
                                    width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(emoji,
                                style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Goal text field
                  Text(
                    'Your goal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: sheetTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'e.g. Drink 8 glasses of water',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: sheetDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: sheetDark ? Colors.grey.shade800 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (controller.text.trim().isNotEmpty) {
                              _addGoal(controller.text, selectedEmoji);
                              Navigator.pop(ctx);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9BE7C4),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                'Add Goal',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
