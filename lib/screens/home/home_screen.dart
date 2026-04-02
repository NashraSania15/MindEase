import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/stress_history_service.dart';
import '../../services/emergency_service.dart';

import '../profile/profile_screen.dart';
import '../face/face_analysis_screen.dart';
import '../voice/voice_analysis_screen.dart';
import '../text/text_analysis_screen.dart';
import '../ai/ai_chat_screen.dart';
import '../meditation/meditation_screen.dart';
import '../goals/goals_screen.dart';
import '../support/support_screen.dart';
import '../combined/final_analysis_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFEFF6F5),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0D0D1A), const Color(0xFF1A1A2E)]
                : [const Color(0xFFF7F7FB), const Color(0xFFEFF6F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${FirebaseAuth.instance.currentUser?.displayName ?? 'there'} 👋',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'How are you feeling today?',
                                style: TextStyle(color: subtextColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF9BE7C4),
                                  Color(0xFF7AD7C1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9BE7C4).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Stress Card — real-time from Firestore ──
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: StressHistoryService.latestTwoEntriesStream(),
                        builder: (context, snapshot) {
                        String emoji = '😊';
                        String label = 'Calm';
                        String levelText = 'Stress Level: Low';
                        String percent = '—';
                        Color borderColor = const Color(0xFF9BE7C4);
                        Color bgTint = const Color(0xFF9BE7C4);
                        double stressVal = 0;

                        // Trend data
                        String trendIcon = '';
                        String trendLabel = '';
                        Color trendColor = Colors.grey;

                        if (snapshot.hasData &&
                            snapshot.data!.docs.isNotEmpty) {
                          final docs = snapshot.data!.docs;
                          final latestData = docs.first.data();
                          stressVal =
                              StressHistoryService.computeStress(latestData);
                          percent = '${stressVal.toStringAsFixed(0)}%';

                          // Compute trend from last 2 entries
                          if (docs.length >= 2) {
                            final prevData = docs[1].data();
                            final prevStress =
                                StressHistoryService.computeStress(prevData);
                            final diff = stressVal - prevStress;

                            if (diff > 5) {
                              trendIcon = '↑';
                              trendLabel = 'Increasing';
                              trendColor = const Color(0xFFE53935);
                            } else if (diff < -5) {
                              trendIcon = '↓';
                              trendLabel = 'Decreasing';
                              trendColor = const Color(0xFF43A047);
                            } else {
                              trendIcon = '→';
                              trendLabel = 'Stable';
                              trendColor = const Color(0xFFFFA726);
                            }
                          }

                          if (stressVal >= 80) {
                            emoji = '🚨';
                            label = 'Critical';
                            levelText = 'Stress Level: Very High';
                            borderColor = const Color(0xFFD32F2F);
                            bgTint = const Color(0xFFD32F2F);
                          } else if (stressVal >= 60) {
                            emoji = '😟';
                            label = 'Stressed';
                            levelText = 'Stress Level: High';
                            borderColor = const Color(0xFFE53935);
                            bgTint = const Color(0xFFE53935);
                          } else if (stressVal >= 40) {
                            emoji = '😐';
                            label = 'Moderate';
                            levelText = 'Stress Level: Moderate';
                            borderColor = const Color(0xFFFFA726);
                            bgTint = const Color(0xFFFFA726);
                          } else if (stressVal >= 20) {
                            emoji = '😌';
                            label = 'Mild';
                            levelText = 'Stress Level: Low';
                            borderColor = const Color(0xFF66BB6A);
                            bgTint = const Color(0xFF66BB6A);
                          }
                        }

                        return Column(
                          children: [
                            // Emergency warning banner
                            if (stressVal >= 75)
                              _EmergencyBanner(stressLevel: stressVal),

                            // Stress card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: borderColor.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: bgTint.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      // Emoji circle
                                      Container(
                                        height: 56,
                                        width: 56,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              bgTint.withOpacity(0.2),
                                              bgTint.withOpacity(0.08),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(emoji,
                                              style: const TextStyle(
                                                  fontSize: 26)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Labels
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Stress',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$label · $levelText',
                                              style: TextStyle(
                                                color: subtextColor,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Percent ring
                                      Container(
                                        height: 52,
                                        width: 52,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: borderColor,
                                            width: 5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            percent,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Trend indicator row
                                  if (trendIcon.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: trendColor.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            trendIcon,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: trendColor,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            trendLabel,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: trendColor,
                                            ),
                                          ),
                                          Text(
                                            ' vs previous',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: subtextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Insight message
                                    const SizedBox(height: 8),
                                    Text(
                                      _trendInsight(trendLabel, stressVal),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: subtextColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Mini Stress Graph ──
                    _MiniStressChart(cardColor: cardColor, textColor: textColor, subtextColor: subtextColor),

                    const SizedBox(height: 24),

                    // ── Feature Grid ──
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio:
                                constraints.maxWidth > 400 ? 1.3 : 1.15,
                            children: [
                              _FeatureCard(
                                title: 'Voice Check',
                                icon: Icons.mic,
                                emoji: '🎙️',
                                gradient: const [
                                  Color(0xFFE8F5E9),
                                  Color(0xFFD0F0E8),
                                ],
                                darkGradient: const [
                                  Color(0xFF1B3A2D),
                                  Color(0xFF1A2E28),
                                ],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const VoiceAnalysisScreen(),
                                  ),
                                ),
                              ),
                              _FeatureCard(
                                title: 'Text Check',
                                icon: Icons.edit,
                                emoji: '✍️',
                                gradient: const [
                                  Color(0xFFE3F2FD),
                                  Color(0xFFBBDEFB),
                                ],
                                darkGradient: const [
                                  Color(0xFF1A2A3A),
                                  Color(0xFF1A2535),
                                ],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const TextAnalysisScreen(),
                                  ),
                                ),
                              ),
                              _FeatureCard(
                                title: 'Face Check',
                                icon: Icons.camera_alt,
                                emoji: '📸',
                                gradient: const [
                                  Color(0xFFFCE4EC),
                                  Color(0xFFF8BBD0),
                                ],
                                darkGradient: const [
                                  Color(0xFF3A1A2A),
                                  Color(0xFF351A28),
                                ],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const FaceAnalysisScreen(),
                                  ),
                                ),
                              ),
                              _FeatureCard(
                                title: 'AI Chat',
                                icon: Icons.smart_toy,
                                emoji: '🤖',
                                gradient: const [
                                  Color(0xFFF3E5F5),
                                  Color(0xFFE1BEE7),
                                ],
                                darkGradient: const [
                                  Color(0xFF2A1A3A),
                                  Color(0xFF251A35),
                                ],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AiChatScreen(),
                                  ),
                                ),
                              ),
                              _FeatureCard(
                                title: 'Meditation',
                                icon: Icons.self_improvement,
                                emoji: '🧘',
                                gradient: const [
                                  Color(0xFFFFF3E0),
                                  Color(0xFFFFE0B2),
                                ],
                                darkGradient: const [
                                  Color(0xFF3A2A1A),
                                  Color(0xFF352A1A),
                                ],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const MeditationScreen(),
                                  ),
                                ),
                              ),
                              _FeatureCard(
                                title: 'Goals',
                                icon: Icons.flag,
                                emoji: '🎯',
                                gradient: const [
                                  Color(0xFFE0F7FA),
                                  Color(0xFFB2EBF2),
                                ],
                                darkGradient: const [
                                  Color(0xFF1A2E3A),
                                  Color(0xFF1A2835),
                                ],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const GoalsScreen(),
                                  ),
                                ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Daily Tip ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Take 3 deep breaths when you feel overwhelmed. '
                              'It helps activate your calm response.',
                              style: TextStyle(color: subtextColor),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Combined Result ──
                    _ActionButton(
                      icon: Icons.analytics_outlined,
                      label: 'Combined Result',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FinalAnalysisScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Support ──
                    _ActionButton(
                      icon: Icons.favorite,
                      label: 'Support',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SupportScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Returns an insight message based on the trend direction and stress value.
  String _trendInsight(String trendLabel, double stressVal) {
    switch (trendLabel) {
      case 'Increasing':
        return stressVal >= 60
            ? 'Your stress is climbing — consider a breathing exercise.'
            : 'Stress is rising slightly. Stay mindful.';
      case 'Decreasing':
        return 'Great progress! Your stress is going down. Keep it up!';
      case 'Stable':
        return stressVal >= 50
            ? 'Stress is holding steady — try a short meditation.'
            : 'You\'re in a good place. Stay consistent!';
      default:
        return '';
    }
  }
}

/// Live mini stress chart — shows the last 3 entries as animated gradient bars.
class _MiniStressChart extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final Color subtextColor;

  const _MiniStressChart({
    required this.cardColor,
    required this.textColor,
    required this.subtextColor,
  });

  // Color based on stress value (0–100).
  static Color _barColor(double stress) {
    if (stress >= 75) return const Color(0xFFE53935);
    if (stress >= 50) return const Color(0xFFFFA726);
    if (stress >= 25) return const Color(0xFF66BB6A);
    return const Color(0xFF9BE7C4);
  }

  static List<Color> _barGradient(double stress) {
    if (stress >= 75) {
      return const [Color(0xFFFF5252), Color(0xFFD32F2F)];
    }
    if (stress >= 50) {
      return const [Color(0xFFFFB74D), Color(0xFFF57C00)];
    }
    if (stress >= 25) {
      return const [Color(0xFF81C784), Color(0xFF43A047)];
    }
    return const [Color(0xFF9BE7C4), Color(0xFF7AD7C1)];
  }

  // Relative time label (e.g. "2 min ago", "1h ago", "3d ago").
  static String _timeLabel(DateTime? dt) {
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.show_chart_rounded,
                  color: isDark
                      ? const Color(0xFF9BE7C4)
                      : const Color(0xFF7AD7C1),
                  size: 22),
              const SizedBox(width: 8),
              Text(
                'Stress Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Text(
                'Last 3',
                style: TextStyle(
                  fontSize: 12,
                  color: subtextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart body — StreamBuilder
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: StressHistoryService.latestEntriesStream(3),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 140,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark
                            ? const Color(0xFF9BE7C4)
                            : const Color(0xFF7AD7C1),
                      ),
                    ),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.grey.withValues(alpha: 0.06),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insert_chart_outlined_rounded,
                            size: 32,
                            color: subtextColor.withValues(alpha: 0.5)),
                        const SizedBox(height: 6),
                        Text(
                          'No stress data yet.\nRun an analysis to see your trend.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: subtextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Build entries in chronological order (oldest → newest).
              final entries = docs.reversed.map((doc) {
                final d = doc.data();
                final stress =
                    StressHistoryService.computeStress(d).clamp(0.0, 100.0);
                final ts = (d['timestamp'] as Timestamp?)?.toDate();
                return _StressEntry(stress: stress, time: ts);
              }).toList();

              const double barAreaHeight = 120;

              return SizedBox(
                height: barAreaHeight + 40, // bars + labels
                child: CustomPaint(
                  painter: _TrendLinePainter(
                    entries: entries,
                    barAreaHeight: barAreaHeight,
                    lineColor: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(entries.length, (i) {
                      final e = entries[i];
                      final barHeight =
                          (e.stress / 100.0 * barAreaHeight).clamp(12.0, barAreaHeight);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Stress value label
                              Text(
                                '${e.stress.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _barColor(e.stress),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Animated bar
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: barHeight),
                                duration: Duration(
                                    milliseconds: 500 + (i * 150)),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) {
                                  return Container(
                                    height: value,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      gradient: LinearGradient(
                                        colors: _barGradient(e.stress),
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _barColor(e.stress)
                                              .withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 6),
                              // Time label
                              Text(
                                _timeLabel(e.time),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: subtextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Simple data holder for a stress entry.
class _StressEntry {
  final double stress;
  final DateTime? time;

  const _StressEntry({required this.stress, this.time});
}

/// Paints a subtle connecting line between the tops of the bars.
class _TrendLinePainter extends CustomPainter {
  final List<_StressEntry> entries;
  final double barAreaHeight;
  final Color lineColor;

  _TrendLinePainter({
    required this.entries,
    required this.barAreaHeight,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // The bar area starts below the value label (~20px) and ends before
    // the time label (~20px), so the bottom of bars is at size.height - 20.
    const topOffset = 20.0; // value label height
    const bottomOffset = 20.0; // time label height
    final drawHeight = size.height - topOffset - bottomOffset;

    final path = ui.Path();
    for (int i = 0; i < entries.length; i++) {
      final x = (size.width / entries.length) * (i + 0.5);
      final normalized = entries[i].stress / 100.0;
      final y = size.height - bottomOffset - (normalized * drawHeight);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots at each point
    final dotPaint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < entries.length; i++) {
      final x = (size.width / entries.length) * (i + 0.5);
      final normalized = entries[i].stress / 100.0;
      final y = size.height - bottomOffset - (normalized * drawHeight);
      dotPaint.color = _MiniStressChart._barColor(entries[i].stress);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter oldDelegate) =>
      entries != oldDelegate.entries;
}

// ═══════════════════════ COMPONENTS ═══════════════════════

/// Red emergency banner shown when stress >= 75%.
/// Automatically triggers the emergency alert (direct SMS, no user interaction)
/// when first built. The 15-min cooldown in EmergencyService prevents duplicates.
class _EmergencyBanner extends StatefulWidget {
  final double stressLevel;
  const _EmergencyBanner({required this.stressLevel});

  @override
  State<_EmergencyBanner> createState() => _EmergencyBannerState();
}

class _EmergencyBannerState extends State<_EmergencyBanner> {
  bool _alertTriggered = false;
  bool _alertSent = false;

  @override
  void initState() {
    super.initState();
    _autoTriggerAlert();
  }

  @override
  void didUpdateWidget(covariant _EmergencyBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-trigger if stress level changed significantly (e.g. new reading)
    if (!_alertTriggered && widget.stressLevel >= 75) {
      _autoTriggerAlert();
    }
  }

  Future<void> _autoTriggerAlert() async {
    if (_alertTriggered) return;
    _alertTriggered = true;

    try {
      final sent = await EmergencyService()
          .triggerEmergencyAlert(widget.stressLevel);
      if (mounted) {
        setState(() => _alertSent = sent);
      }
    } catch (_) {
      // Silent — don't crash the dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ High Stress Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _alertSent
                      ? 'Stress at ${widget.stressLevel.toStringAsFixed(0)}%. Emergency contacts have been notified.'
                      : 'Stress at ${widget.stressLevel.toStringAsFixed(0)}%. Emergency alert on cooldown.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Feature card with emoji, gradient, hover scale animation.
class _FeatureCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String emoji;
  final List<Color> gradient;
  final List<Color> darkGradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.emoji,
    required this.gradient,
    required this.darkGradient,
    required this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnim =
        Tween<double>(begin: 1.0, end: 0.96).animate(_scaleCtrl);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) {
        _scaleCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: isDark ? widget.darkGradient : widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withOpacity(isDark ? 0.1 : 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji,
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isDark ? const Color(0xFF9BE7C4) : Colors.redAccent),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
