import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:advisor_bot/features/onboarding/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");  // Ensure it's loaded before the app starts
  runApp(const AdvisorBotApp());
}

class AdvisorBotApp extends StatelessWidget {
  const AdvisorBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advisor Bot',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OnboardingScreen(),  // Make sure this points to the onboarding screen
    );
  }
}
