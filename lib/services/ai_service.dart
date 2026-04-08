// 3. ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String apiKey = "YOUR_APIKEY";
  static const String _endpoint = "https://api.openai.com/v1/chat/completions";

  static Future<String> sendMessage(String message, {List<Map<String, String>> history = const []}) async {
    try {
      final List<Map<String, String>> messages = [...history];
      messages.add({"role": "user", "content": message});

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"];
      } else {
        return "Sorry, I couldn't process that.";
      }
    } catch (e) {
      return "Network error. Please check your connection.";
    }
  }
}