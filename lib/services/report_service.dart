import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report_model.dart';

class ReportService {
  static const String _reportsKey = 'saved_reports';

  /// Save a new report to shared_preferences
  static Future<void> saveReport(ReportModel report) async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getStringList(_reportsKey) ?? [];
    
    // Add new report to the list
    reportsJson.add(jsonEncode(report.toJson()));
    
    // Save updated list
    await prefs.setStringList(_reportsKey, reportsJson);
  }

  /// Fetch all saved reports
  static Future<List<ReportModel>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getStringList(_reportsKey) ?? [];
    
    return reportsJson
        .map((item) => ReportModel.fromJson(jsonDecode(item)))
        .toList()
        .reversed // Show latest reports first
        .toList();
  }
}
