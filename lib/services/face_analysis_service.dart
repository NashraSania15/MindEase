import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FaceAnalysisResult {
  final double stressLevel; // 0–100
  final String emotion;

  const FaceAnalysisResult({
    required this.stressLevel,
    required this.emotion,
  });

  factory FaceAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FaceAnalysisResult(
      stressLevel: (json['stress_level'] as num).toDouble(),
      emotion: json['emotion'] as String,
    );
  }
}

class FaceAnalysisService {
  static const String _baseUrl = 'http://192.168.31.145:5000';

  /// Sends an image [file] to the backend and returns a [FaceAnalysisResult].
  /// Throws a descriptive [Exception] on any failure.
  static Future<FaceAnalysisResult> analyzeFace(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/analyze-face');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return FaceAnalysisResult.fromJson(json);
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
      if (e is Exception &&
          e.toString().contains('Server error')) {
        rethrow;
      }
      throw Exception(
        'Could not reach the server. Please check your connection and try again.',
      );
    }
  }
}
