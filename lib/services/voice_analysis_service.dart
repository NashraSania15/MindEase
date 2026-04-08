import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class VoiceAnalysisResult {
  final double stressLevel; // 0–100
  final String emotion;

  const VoiceAnalysisResult({
    required this.stressLevel,
    required this.emotion,
  });

  factory VoiceAnalysisResult.fromJson(Map<String, dynamic> json) {
    return VoiceAnalysisResult(
      stressLevel: (json['stress_level'] as num).toDouble(),
      emotion: json['emotion'] as String,
    );
  }
}

class VoiceAnalysisService {
  static const String _baseUrl = 'http://192.168.1.20:5000';

  /// Sends an audio [file] to the backend and returns a [VoiceAnalysisResult].
  /// Throws a descriptive [Exception] on any failure.
  static Future<VoiceAnalysisResult> analyzeVoice(File audioFile) async {
    final uri = Uri.parse('$_baseUrl/analyze-voice');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('audio', audioFile.path),
      );

      final streamedResponse =
      await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return VoiceAnalysisResult.fromJson(json);
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
