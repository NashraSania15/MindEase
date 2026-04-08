import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../services/pdf_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<ReportModel> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    final reports = await ReportService.getReports();
    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFEFF6F5),
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? _buildEmptyState(textColor, subtextColor)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return _reportCard(report, cardColor, textColor, subtextColor);
                  },
                ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color subtextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 60, color: subtextColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No Reports Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Your stress analysis reports will appear here after you save them from the Final Analysis screen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: subtextColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(ReportModel report, Color cardColor, Color textColor, Color subtextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report.date,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: subtextColor,
                ),
              ),
              _stressBadge(report.combined),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.emoji_emotions_outlined, size: 18, color: Colors.teal.shade300),
              const SizedBox(width: 8),
              Text(
                'Emotion: ',
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
              ),
              Text(
                report.emotion,
                style: TextStyle(color: subtextColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 18, color: Colors.teal.shade300),
              const SizedBox(width: 8),
              Text(
                'Overall Stress: ',
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
              ),
              Text(
                '${report.combined}%',
                style: TextStyle(
                  color: _getStressColor(report.combined),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => PdfService.generateAndPrintReport(report),
                icon: const Icon(Icons.download, size: 18, color: Colors.teal),
                label: const Text(
                  'Download PDF',
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _stressBadge(int level) {
    final color = _getStressColor(level);
    String label = 'Calm';
    if (level >= 70) label = 'High';
    else if (level >= 40) label = 'Moderate';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStressColor(int level) {
    if (level >= 70) return Colors.redAccent;
    if (level >= 40) return Colors.orangeAccent;
    return Colors.greenAccent.shade700;
  }
}
