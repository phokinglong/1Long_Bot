import 'package:flutter/material.dart';
import 'package:advisor_bot/features/onboarding/onboarding_screen.dart';
import 'package:advisor_bot/features/chatbot/chatbot_screen.dart';

class AdvisorBotApp extends StatelessWidget {
  const AdvisorBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advisor Bot',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/chatbot') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ChatbotScreen(agentName: args['agentName']),
          );
        }
        return MaterialPageRoute(builder: (context) => const OnboardingScreen());
      },
    );
  }
}
