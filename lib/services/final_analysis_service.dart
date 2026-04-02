import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FinalAnalysisResult {
  final double stressLevel;
  final String message;
  final String suggestion;
  final String exercise;

  const FinalAnalysisResult({
    required this.stressLevel,
    required this.message,
    required this.suggestion,
    required this.exercise,
  });

  factory FinalAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FinalAnalysisResult(
      stressLevel: (json['stress_level'] as num).toDouble(),
      message: json['message'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
      exercise: json['exercise'] as String? ?? '',
    );
  }
}

class FinalAnalysisService {
  static const String _baseUrl = 'http://192.168.31.145:5000';

  static Future<FinalAnalysisResult> analyzeAll({
    required String text,
    File? imageFile,
    File? audioFile,
  }) async {
    final uri = Uri.parse('$_baseUrl/analyze-all');

    try {
      final request = http.MultipartRequest('POST', uri);
      if (text.isNotEmpty) {
        request.fields['text'] = text;
      }
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }
      if (audioFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('audio', audioFile.path),
        );
      }

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return FinalAnalysisResult.fromJson(json);
      } else {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      }
    } on SocketException {
      throw Exception(
        'Could not reach the server. Please check your connection and try again.',
      );
    } catch (e) {
      if (e is Exception && e.toString().contains('Server error')) {
        rethrow;
      }
      throw Exception(
        'Could not reach the server. Please check your connection and try again.',
      );
    }
  }
}
