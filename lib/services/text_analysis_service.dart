import 'dart:convert';
import 'package:http/http.dart' as http;

class TextAnalysisResult {
  final double stressLevel; // 0–100
  final String emotion;

  const TextAnalysisResult({
    required this.stressLevel,
    required this.emotion,
  });

  factory TextAnalysisResult.fromJson(Map<String, dynamic> json) {
    return TextAnalysisResult(
      stressLevel: (json['stress_level'] as num).toDouble(),
      emotion: json['emotion'] as String,
    );
  }
}

class TextAnalysisService {
  static const String _baseUrl = 'http://192.168.1.20:5000';

  /// Sends [text] to the backend and returns a [TextAnalysisResult].
  /// Throws a descriptive [Exception] on any failure.
  static Future<TextAnalysisResult> analyzeText(String text) async {
    final uri = Uri.parse('$_baseUrl/analyze-text');

    late http.Response response;

    try {
      response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception(
        'Could not reach the server. Please check your connection and try again.',
      );
    }

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return TextAnalysisResult.fromJson(json);
    } else {
      throw Exception(
        'Server error (${response.statusCode}). Please try again later.',
      );
    }
  }
}
