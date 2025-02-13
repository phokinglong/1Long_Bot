import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String apiUrl = "https://api.openai.com/v1/chat/completions";

  // Store session progress for conversation flow
  static Map<String, int> userProgress = {}; 

  static Future<String> getAIResponse(String advisorName, String userId, String userInput) async {
    if (apiKey.isEmpty) {
      return "Error: API Key is missing! Please check your .env file.";
    }

    // Determine the current step in the conversation
    int step = userProgress[userId] ?? 0;
    
    final String advisorPrompt = getAdvisorPrompt(advisorName, step);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "gpt-4-turbo",
          "messages": [
            {"role": "system", "content": advisorPrompt},
            {"role": "user", "content": userInput}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String botResponse = data["choices"][0]["message"]["content"];
        
        // Move user to the next step in conversation flow
        userProgress[userId] = step + 1;

        return botResponse;
      } else {
        return "Error: OpenAI API returned status code ${response.statusCode}.\n${response.body}";
      }
    } catch (e) {
      return "Error: Failed to communicate with OpenAI. ${e.toString()}";
    }
  }

  // Get the specific prompt based on the conversation step
  static String getAdvisorPrompt(String advisorName, int step) {
    switch (advisorName) {
      case 'The Growth Maximizer':
        return getGrowthMaximizerPrompt(step);

      case 'The Conservative Guardian':
        return getConservativeGuardianPrompt(step);

      case 'The Balanced Mentor':
        return getBalancedMentorPrompt(step);

      case 'The Crypto Visionary':
        return getCryptoVisionaryPrompt(step);

      default:
        return "You are an AI providing financial advisory services.";
    }
  }

  static String getGrowthMaximizerPrompt(int step) {
    switch (step) {
      case 0:
        return "You are The Growth Maximizer, an AI financial advisor focused on high-risk, high-reward investments. Ask the user about their risk tolerance (low, medium, high). Keep it short.";
      
      case 1:
        return "Now that we know the user's risk tolerance, ask about their preferred industries: Tech, Biotech, Crypto, or Emerging Markets.";

      case 2:
        return "Given the user's selected industries, suggest 2-3 high-growth investment strategies in a concise way.";

      default:
        return "Summarize the investment strategy based on the user's inputs. Keep it simple and provide next steps.";
    }
  }

  static String getConservativeGuardianPrompt(int step) {
    switch (step) {
      case 0:
        return "You are The Conservative Guardian. Ask the user about their primary financial goal: retirement, wealth preservation, or low-risk growth.";

      case 1:
        return "Now that we know the goal, ask about their ideal investment time frame: short-term (1-3 years), medium-term (3-7 years), or long-term (7+ years).";

      case 2:
        return "Given the user's goal and time frame, suggest a diversified low-risk portfolio with conservative investments.";

      default:
        return "Summarize the conservative investment plan based on the user's inputs.";
    }
  }

  static String getBalancedMentorPrompt(int step) {
    switch (step) {
      case 0:
        return "You are The Balanced Mentor. Ask the user if they prefer an even split of high and low-risk investments or a weighted strategy.";
      
      case 1:
        return "Now that we know their risk balance, ask if they want to focus on stocks, bonds, real estate, or a mix.";

      case 2:
        return "Provide a balanced portfolio suggestion based on the user's preferences.";

      default:
        return "Summarize the balanced investment plan.";
    }
  }

  static String getCryptoVisionaryPrompt(int step) {
    switch (step) {
      case 0:
        return "You are The Crypto Visionary. Ask the user if they are experienced or new to crypto investing.";
      
      case 1:
        return "Now that we know their experience level, ask if they prefer long-term holding, staking, or active trading.";

      case 2:
        return "Suggest a tailored crypto investment approach.";

      default:
        return "Summarize the recommended crypto strategy.";
    }
  }
}
