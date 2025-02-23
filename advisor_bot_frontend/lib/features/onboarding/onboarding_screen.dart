import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_bot/features/onboarding/onboarding_form.dart';
import 'package:advisor_bot/features/advisors/advisor_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  /// This function is called when the user finishes entering onboarding data.
  Future<void> _saveProfileAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();

    // Mark profile as saved
    await prefs.setBool('profile_saved', true);

    // Navigate to the AdvisorSelectionScreen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdvisorSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thiết lập hồ sơ tài chính',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Pass _saveProfileAndNavigate into the form
        child: OnboardingForm(onComplete: _saveProfileAndNavigate),
      ),
    );
  }
}
