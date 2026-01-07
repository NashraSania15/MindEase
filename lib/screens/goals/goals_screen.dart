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

  void _addGoal(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      goals.add({'title': text, 'icon': '🎯', 'done': false});
    });
  }

  @override
  Widget build(BuildContext context) {
    final completed = goals.where((g) => g['done']).length;
    final progress = completed / goals.length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Today's Wellness Goals",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  const Text('🌱'),
                  const SizedBox(width: 6),
                  Text('$completed of ${goals.length} completed',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),

              const SizedBox(height: 20),

              // Progress card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Today's Progress"),
                        Text('${(progress * 100).round()}%'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade300,
                      color: const Color(0xFF9BE7C4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Goals list
              ...goals.map((goal) => _goalTile(goal)).toList(),

              const SizedBox(height: 16),

              // Add goal button
              GestureDetector(
                onTap: () => _showAddGoalDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9BE7C4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      '+ Add New Goal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Motivation card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8A3),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '✨ Keep Going!\n\n'
                      'Small habits reduce stress over time. '
                      'You’re building a healthier, calmer you.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalTile(Map<String, dynamic> goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: goal['done']
            ? const Color(0xFFEAFBF6)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Checkbox(
            value: goal['done'],
            onChanged: (val) {
              setState(() {
                goal['done'] = val!;
              });
            },
          ),
          const SizedBox(width: 6),
          Text(goal['icon'], style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              goal['title'],
              style: TextStyle(
                decoration:
                goal['done'] ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Goal'),
        content: TextField(
          controller: controller,
          decoration:
          const InputDecoration(hintText: 'Enter your goal'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addGoal(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
