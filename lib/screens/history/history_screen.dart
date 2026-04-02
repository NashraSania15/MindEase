import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../services/stress_history_service.dart';

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
    final textColor = isDark ? Colors.white : Colors.black87;
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
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: StressHistoryService.historyStream(),
            builder: (context, snapshot) {
              final allDocs = snapshot.data?.docs ?? [];

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
                                  color: Colors.black.withOpacity(0.04),
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
                    _buildChart(allDocs),

                    const SizedBox(height: 20),

                    // Stats + entries
                    _buildContent(allDocs),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── CHART ──────────────────────────────────────────

  Widget _buildChart(List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (selectedTab == 0) {
      // ── DAILY: show individual entries from last 7 days ──
      final cutoff = today.subtract(const Duration(days: 7));
      final points = <_ChartPoint>[];

      for (final doc in allDocs.reversed) {
        final ts = doc.data()['timestamp'] as Timestamp?;
        if (ts == null) continue;
        final date = ts.toDate();
        if (date.isBefore(cutoff)) continue;
        final stress = StressHistoryService.computeStress(doc.data());
        points.add(_ChartPoint(date: date, stress: stress));
      }

      return _chartContainer(
        title: 'Daily Stress Trend',
        points: points,
        labelFormatter: (d) => DateFormat('MM/dd').format(d),
      );
    } else {
      // ── WEEKLY: group by week (last 4 weeks), average per week ──
      final cutoff = today.subtract(const Duration(days: 28));
      final weekBuckets = <int, List<double>>{};

      for (final doc in allDocs) {
        final ts = doc.data()['timestamp'] as Timestamp?;
        if (ts == null) continue;
        final date = ts.toDate();
        if (date.isBefore(cutoff)) continue;
        final weeksAgo = today.difference(DateTime(date.year, date.month, date.day)).inDays ~/ 7;
        weekBuckets.putIfAbsent(weeksAgo, () => []);
        weekBuckets[weeksAgo]!.add(StressHistoryService.computeStress(doc.data()));
      }

      final points = <_ChartPoint>[];
      for (int w = 3; w >= 0; w--) {
        final weekStart = today.subtract(Duration(days: w * 7 + 6));
        final stresses = weekBuckets[w] ?? [];
        final avg = stresses.isNotEmpty
            ? stresses.reduce((a, b) => a + b) / stresses.length
            : 0.0;
        points.add(_ChartPoint(date: weekStart, stress: avg));
      }

      return _chartContainer(
        title: 'Weekly Stress Trend',
        points: points,
        labelFormatter: (d) => 'W${DateFormat('MM/dd').format(d)}',
      );
    }
  }

  Widget _chartContainer({
    required String title,
    required List<_ChartPoint> points,
    required String Function(DateTime) labelFormatter,
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
                    labelFormatter: labelFormatter,
                  ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── CONTENT ────────────────────────────────────────

  Widget _buildContent(List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDays = selectedTab == 0 ? 7 : 28;
    final cutoff = today.subtract(Duration(days: maxDays));

    final filtered = allDocs.where((doc) {
      final ts = doc.data()['timestamp'] as Timestamp?;
      if (ts == null) return false;
      return ts.toDate().isAfter(cutoff);
    }).toList();

    // Compute stats
    final entryCount = filtered.length;
    double bestStress = 100;
    
    for (final doc in filtered) {
      final stress = StressHistoryService.computeStress(doc.data());
      if (stress < bestStress && stress > 0) bestStress = stress;
    }

    final currentStress = filtered.isNotEmpty
        ? StressHistoryService.computeStress(filtered.first.data())
        : 0.0;
    if (entryCount == 0) bestStress = 0;
    final bestEmoji = entryCount == 0
        ? '—'
        : (bestStress < 30 ? '😊' : (bestStress < 60 ? '😐' : '😔'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Current Stress',
                value: entryCount > 0 ? '${currentStress.toStringAsFixed(0)}%' : '—',
                icon: Icons.monitor_heart,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Best Mood',
                value: bestEmoji,
                icon: Icons.emoji_emotions,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Entries',
                value: '$entryCount',
                icon: Icons.book,
                color: Colors.blue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Daily tab → show recent individual entries
        // Weekly tab → show aggregated weekly summaries only
        if (selectedTab == 0) ...[
          const Text(
            'Recent Entries',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No entries yet. Analyze your stress to see results here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ...filtered.map((doc) {
            final d = doc.data();
            final ts = d['timestamp'] as Timestamp?;
            final date = ts != null
                ? DateFormat('MMM d, h:mm a').format(ts.toDate())
                : '—';
            final stress = StressHistoryService.computeStress(d);

            String mood;
            if (stress >= 80) {
              mood = '😨 High';
            } else if (stress >= 60) {
              mood = '😟 Stressed';
            } else if (stress >= 30) {
              mood = '😐 Moderate';
            } else {
              mood = '😊 Calm';
            }

            return _entryTile(
              date: date,
              mood: mood,
              stress: '${stress.toStringAsFixed(0)}%',
            );
          }),
        ] else ...[
          // Weekly aggregated view
          const Text(
            'Weekly Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ..._buildWeeklySummaries(allDocs),
        ],
      ],
    );
  }

  List<Widget> _buildWeeklySummaries(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final summaries = <Widget>[];

    for (int w = 0; w < 4; w++) {
      final weekEnd = today.subtract(Duration(days: w * 7));
      final weekStart = today.subtract(Duration(days: w * 7 + 6));

      final weekDocs = allDocs.where((doc) {
        final ts = doc.data()['timestamp'] as Timestamp?;
        if (ts == null) return false;
        final d = ts.toDate();
        return !d.isBefore(weekStart) && !d.isAfter(weekEnd.add(const Duration(days: 1)));
      }).toList();

      if (weekDocs.isEmpty) continue;

      final stresses = weekDocs.map((d) => StressHistoryService.computeStress(d.data())).toList();
      final avg = stresses.reduce((a, b) => a + b) / stresses.length;
      final label = '${DateFormat('MMM d').format(weekStart)} – ${DateFormat('MMM d').format(weekEnd)}';

      String emoji;
      if (avg >= 80) {
        emoji = '😨';
      } else if (avg >= 60) {
        emoji = '😟';
      } else if (avg >= 30) {
        emoji = '😐';
      } else {
        emoji = '😊';
      }

      summaries.add(
        Container(
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
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
                    const SizedBox(height: 4),
                    Text(
                      '${weekDocs.length} entries · Avg ${avg.toStringAsFixed(0)}%',
                      style: TextStyle(color: subtextColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '${avg.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: avg >= 60
                      ? const Color(0xFFE53935)
                      : avg >= 30
                          ? const Color(0xFFFFA726)
                          : const Color(0xFF43A047),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (summaries.isEmpty) {
      summaries.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No data in the last 4 weeks.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return summaries;
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
  final DateTime date;
  final double stress;
  const _ChartPoint({required this.date, required this.stress});
}

class _SimpleLineChart extends StatelessWidget {
  final List<_ChartPoint> points;
  final String Function(DateTime) labelFormatter;

  const _SimpleLineChart({
    required this.points,
    required this.labelFormatter,
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
            labelFormatter: labelFormatter,
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
  final String Function(DateTime) labelFormatter;

  _ChartPainter({
    required this.points,
    required this.chartHeight,
    required this.maxStress,
    required this.labelFormatter,
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
      final lbl = labelFormatter(points[i].date);
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
