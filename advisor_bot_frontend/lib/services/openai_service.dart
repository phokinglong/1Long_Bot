import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';

  // ✅ Updated agent mapping to match backend structure
  static final Map<String, String> advisorEndpoints = {
    "Cộng sự Chi tiêu": "/api/spending",
    "Cộng sự Tích lũy": "/api/savings",
    "Cộng sự Đầu tư": "/api/investment",
    "Cộng sự Tin tức": "/api/news",
  };

  /// Fetch AI response based on selected advisor
  static Future<String> getAIResponse(String advisorName, Map<String, dynamic> userInput) async {
    if (!advisorEndpoints.containsKey(advisorName)) {
      return "❌ Error: Invalid advisor selection.";
    }

    final String endpoint = advisorEndpoints[advisorName]!;
    final Uri url = Uri.parse("$baseUrl$endpoint");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(userInput),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["plan"] ?? "❌ Error: No response from AI.";
      } else {
        return "❌ API Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "❌ Network Error: Failed to connect to AI API.\n$e";
    }
  }
}
