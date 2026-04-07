import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../services/stress_history_service.dart';
import '../../models/stress_entry.dart';



class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedTab = 0; // 0 = Daily, 1 = Weekly  

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

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
          child: StreamBuilder<List<StressEntry>>(
            stream: StressHistoryService.dailyStream,
            builder: (context, dailySnapshot) {
              return StreamBuilder<List<WeeklyEntry>>(
                stream: StressHistoryService.weeklyStream,
                builder: (context, weeklySnapshot) {
                  final dailyEntries = dailySnapshot.data ?? [];
                  final weeklyHistory = weeklySnapshot.data ?? [];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          'Your Emotional Journey',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Track how your mood and stress change over time',
                          style: TextStyle(color: subtextColor),
                        ),

                        const SizedBox(height: 20),

                        // Daily / Weekly toggle
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              _toggleButton('Daily', 0),
                              _toggleButton('Weekly', 1),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Real-time chart
                        _buildChart(dailyEntries, weeklyHistory),

                        const SizedBox(height: 20),

                        // Stats + entries
                        _buildContent(dailyEntries, weeklyHistory),
                      ],
                    ),
                  );
                }
              );
            },
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── CHART ──────────────────────────────────────────

  Widget _buildChart(List<StressEntry> daily, List<WeeklyEntry> weekly) {
    if (selectedTab == 0) {
      // ── DAILY: show individual entries from today ──
      final points = daily.map((e) => _ChartPoint(
        label: e.timestamp, 
        stress: e.combinedStress
      )).toList();

      return _chartContainer(
        title: 'Today\'s Stress Trend',
        points: points,
      );
    } else {
      // ── WEEKLY: show daily averages from the last few days ──
      final points = weekly.map((w) {
        final avg = w.entries.fold<double>(0, (sum, e) => sum + e.combinedStress) / w.entries.length;
        return _ChartPoint(label: w.day.substring(0, 3), stress: avg);
      }).toList();

      return _chartContainer(
        title: 'Weekly Average Trend',
        points: points,
      );
    }
  }

  Widget _chartContainer({
    required String title,
    required List<_ChartPoint> points,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Container(
      height: 220,
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
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
          const SizedBox(height: 12),
          Expanded(
            child: points.isEmpty
                ? Center(
                    child: Text(
                      'No data yet',
                      style: TextStyle(color: subtextColor),
                    ),
                  )
                : _SimpleLineChart(
                    points: points,
                  ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── CONTENT ────────────────────────────────────────

  Widget _buildContent(List<StressEntry> daily, List<WeeklyEntry> weekly) {
    if (selectedTab == 0) {
      // Today Stats
      final latestStress = daily.isNotEmpty ? daily.last.combinedStress : 0.0;
      final count = daily.length;
      
      String statusEmoji = '😊';
      if (latestStress >= 80) statusEmoji = '😨';
      else if (latestStress >= 60) statusEmoji = '😟';
      else if (latestStress >= 30) statusEmoji = '😐';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Latest Stress',
                  value: daily.isNotEmpty ? '${latestStress.toStringAsFixed(0)}%' : '—',
                  icon: Icons.monitor_heart,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Today State',
                  value: statusEmoji,
                  icon: Icons.emoji_emotions,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Analyses',
                  value: '$count',
                  icon: Icons.assignment_turned_in,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Today\'s Entries',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (daily.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No entries today yet.', style: TextStyle(color: Colors.grey)),
            )),
          ...daily.reversed.map((e) => _entryTile(
            date: e.timestamp,
            mood: e.emotion.isNotEmpty ? e.emotion : 'Analyzed',
            stress: '${e.combinedStress.toStringAsFixed(0)}%',
          )),
        ],
      );
    } else {
      // Weekly Content
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (weekly.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No historical data yet.', style: TextStyle(color: Colors.grey)),
            )),
          ...weekly.reversed.map((w) {
            final avg = w.entries.fold<double>(0, (sum, e) => sum + e.combinedStress) / w.entries.length;
            String emoji = '😊';
            if (avg >= 80) emoji = '😨';
            else if (avg >= 60) emoji = '😟';
            else if (avg >= 30) emoji = '😐';

            return _weeklyTile(
              label: w.day,
              date: w.date,
              avg: avg,
              count: w.entries.length,
              emoji: emoji,
            );
          }),
        ],
      );
    }
  }

  Widget _weeklyTile({
    required String label,
    required String date,
    required double avg,
    required int count,
    required String emoji,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$label, $date', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                Text('$count entries recorded', style: TextStyle(color: subtextColor, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${avg.toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: avg >= 60 ? Colors.red : (avg >= 30 ? Colors.orange : Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── SHARED WIDGETS ────────────────────────────────

  Widget _toggleButton(String text, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
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
                color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.grey),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _entryTile({
    required String date,
    required String mood,
    required String stress,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
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
      child: Row(
        children: [
          Expanded(
            child: Text(
              date,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(mood, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Text(
            stress,
            style: TextStyle(color: subtextColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════ SIMPLE LINE CHART ═══════════════════════════════

class _ChartPoint {
  final String label;
  final double stress;
  const _ChartPoint({required this.label, required this.stress});
}

class _SimpleLineChart extends StatelessWidget {
  final List<_ChartPoint> points;

  const _SimpleLineChart({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final chartH = h - 24; // reserve bottom for labels
        const maxStress = 100.0;

        return CustomPaint(
          size: Size(w, h),
          painter: _ChartPainter(
            points: points,
            chartHeight: chartH,
            maxStress: maxStress,
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<_ChartPoint> points;
  final double chartHeight;
  final double maxStress;

  _ChartPainter({
    required this.points,
    required this.chartHeight,
    required this.maxStress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final n = points.length;
    final segW = n > 1 ? size.width / (n - 1) : size.width;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 0.5;

    for (int pct = 0; pct <= 100; pct += 25) {
      final y = chartHeight - (pct / maxStress * chartHeight);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Line + fill
    final linePaint = Paint()
      ..color = const Color(0xFF7AD7C1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x559BE7C4), Color(0x009BE7C4)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));

    final linePath = Path();
    final fillPath = Path();
    final dotPositions = <Offset>[];

    for (int i = 0; i < n; i++) {
      final x = n > 1 ? i * segW : size.width / 2;
      final y = chartHeight - (points[i].stress / maxStress * chartHeight);
      dotPositions.add(Offset(x, y));

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Close fill path
    fillPath.lineTo(dotPositions.last.dx, chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    // Dots + labels
    final dotPaint = Paint()..color = const Color(0xFF7AD7C1);
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final labelStyle = const TextStyle(
      color: Color(0xFF999999),
      fontSize: 10,
    );

    for (int i = 0; i < n; i++) {
      final pos = dotPositions[i];

      // Dot
      canvas.drawCircle(pos, 4, dotPaint);
      canvas.drawCircle(pos, 4, dotBorderPaint);

      // Value label above dot
      final valuePainter = TextPainter(
        text: TextSpan(
          text: points[i].stress.toStringAsFixed(0),
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      valuePainter.paint(
        canvas,
        Offset(pos.dx - valuePainter.width / 2, pos.dy - 16),
      );

      // X-axis label
      final lbl = points[i].label;
      final tp = TextPainter(
        text: TextSpan(text: lbl, style: labelStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(pos.dx - tp.width / 2, chartHeight + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ═══════════════════════════ STAT CARD ═══════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: Theme.of(context).brightness == Brightness.dark
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
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey),
          ),
        ],
      ),
    );
  }
}
