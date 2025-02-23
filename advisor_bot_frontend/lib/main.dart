import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_bot/features/intro/intro_screen.dart';
import 'package:advisor_bot/features/onboarding/onboarding_screen.dart';
import 'package:advisor_bot/features/advisors/advisor_selection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load environment variables
  runApp(const AdvisorBotApp());
}

class AdvisorBotApp extends StatelessWidget {
  const AdvisorBotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advisor Bot',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const InitialScreen(),
    );
  }
}

/// Checks if user has seen intro and/or completed onboarding, 
/// then navigates to the appropriate first screen.
class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool? hasSeenIntro;
  bool? profileSaved;

  @override
  void initState() {
    super.initState();
    _checkUserProgress();
  }

  Future<void> _checkUserProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // If the user has previously completed the intro:
    final bool seenIntro = prefs.getBool('seen_intro') ?? false;
    // If the user has completed (saved) their onboarding profile:
    final bool savedProfile = prefs.getBool('profile_saved') ?? false;

    setState(() {
      hasSeenIntro = seenIntro;
      profileSaved = savedProfile;
    });

    // If we haven't seen the intro yet, set it now so it won't repeat.
    if (!seenIntro) {
      await prefs.setBool('seen_intro', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading spinner while reading from SharedPreferences
    if (hasSeenIntro == null || profileSaved == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If user hasn't seen the intro yet, show IntroScreen
    if (!hasSeenIntro!) {
      return const IntroScreen();
    } 
    // If user hasn't saved their profile, show OnboardingScreen
    else if (!profileSaved!) {
      return const OnboardingScreen();
    } 
    // Otherwise, go to advisor selection
    else {
      return const AdvisorSelectionScreen();
    }
  }
}
