import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class FinalAnalysisResult {
  final double stressLevel;
  final String stressCategory;
  final String emotion;
  final String message;
  final String futureSimulation;
  final String reason;

  const FinalAnalysisResult({
    required this.stressLevel,
    required this.stressCategory,
    required this.emotion,
    required this.message,
    required this.futureSimulation,
    required this.reason,
  });

  factory FinalAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FinalAnalysisResult(
      stressLevel: (json['stress_level'] as num?)?.toDouble() ?? 0.0,
      stressCategory: json['stress_category'] as String? ?? 'Moderate Stress',
      emotion: json['emotion'] as String? ?? 'neutral',
      message: json['message'] as String? ?? 'Take care of your mental health.',
      futureSimulation: json['future_simulation'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class FinalAnalysisService {
  // Use correct URL: 
  // Emulator -> http://10.0.2.2:5000
  // Real device -> http://<local-ip>:5000
  static String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000';
    } else {
      // Replace with your actual local IP if running on a real iOS device, e.g., 'http://192.168.1.x:5000'
      return 'http://192.168.1.20:5000';
    }
  }

  static Future<FinalAnalysisResult> analyzeAll({
    required String text,
    File? imageFile,
    File? audioFile,
  }) async {
    print('API CALL START');
    final uri = Uri.parse('http://192.168.1.20:5000/combined-result');

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
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      print('RESPONSE RECEIVED');
      
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('ERROR OCCURRED');
          throw Exception('Server not responding');
        }

        final dynamic json = jsonDecode(response.body);
        print("API RESPONSE: $json");
        if (json == null || json is! Map<String, dynamic>) {
          print('ERROR OCCURRED');
          throw Exception('Server not responding');
        }

        return FinalAnalysisResult.fromJson(json);
      } else {
        print('ERROR OCCURRED');
        throw Exception('Server not responding');
      }
    } on TimeoutException {
      print('ERROR OCCURRED');
      throw Exception('Server not responding');
    } on SocketException {
      print('ERROR OCCURRED');
      throw Exception('Server not responding');
    } catch (e) {
      print('ERROR OCCURRED');
      throw Exception('Server not responding');
    }
  }
}
