import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_bot/features/onboarding/onboarding_screen.dart';
import 'package:advisor_bot/features/advisors/spending_agent_screen.dart';
import 'package:advisor_bot/features/advisors/savings_agent_screen.dart';
import 'package:advisor_bot/features/advisors/investment_agent_screen.dart';
import 'package:advisor_bot/features/advisors/news_agent_screen.dart';
import 'package:advisor_bot/features/advisors/research_agent_screen.dart';


class AdvisorSelectionScreen extends StatefulWidget {
  const AdvisorSelectionScreen({super.key});

  @override
  AdvisorSelectionScreenState createState() => AdvisorSelectionScreenState();
}

class AdvisorSelectionScreenState extends State<AdvisorSelectionScreen> {
  @override
  void initState() {
    super.initState();
    _checkProfileStatus();
  }

  /// ✅ **Check if user has completed onboarding**
  Future<void> _checkProfileStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool profileSaved = prefs.getBool('profile_saved') ?? false;

    if (!profileSaved && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  /// ✅ **Send advisor selection to backend**
  Future<void> sendAdvisorSelection(int agentId) async {
    final requestBody = jsonEncode({"agent_id": agentId});

    try {
      final response = await http.post(
        Uri.parse("https://your-backend-api.com/advisor"), // Replace with actual API
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (response.statusCode != 200) {
        debugPrint("Error selecting advisor: ${response.body}");
      }
    } catch (error) {
      debugPrint("Network error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> advisors = [
      {
        'id': 1,
        'name': 'Cộng sự "Chi tiêu"',
        'description': 'Quản lý chi tiêu cá nhân / gia đình.',
        'icon': Icons.account_balance_wallet,
        'color': Colors.blue
      },
      {
        'id': 2,
        'name': 'Cộng sự "Tích lũy"',
        'description': 'Tích lũy và bảo hiểm cá nhân.',
        'icon': Icons.savings,
        'color': Colors.green
      },
      {
        'id': 3,
        'name': 'Cộng sự "Đầu tư"',
        'description': 'Chiến lược đầu tư tài chính.',
        'icon': Icons.trending_up,
        'color': Colors.orange
      },
      {
        'id': 4,
        'name': 'Cộng sự "Tin tức"',
        'description': 'Phân tích tin tức tài chính, thị trường.',
        'icon': Icons.newspaper,
        'color': Colors.purple
      },
      {
        'id': 5,
        'name': 'Cộng sự "Nghiên cứu"',
        'description': 'Tra cứu cổ phiếu, báo cáo tài chính, v.v.',
        'icon': Icons.search,
        'color': Colors.blueGrey
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background Image Overlay
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png", // Make sure the image exists in assets
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Content Overlay
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Chọn Cộng sự AI của bạn',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    children: advisors.map((advisor) {
                      return Card(
                        color: Colors.black.withOpacity(0.85), // Darkened transparency
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: advisor['color']!, width: 2),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: advisor['color']!.withOpacity(0.2),
                            child: Icon(advisor['icon'], color: advisor['color']),
                          ),
                          title: Text(
                            advisor['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            advisor['description'],
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              int agentId = advisor['id'];
                              await sendAdvisorSelection(agentId);

                              if (!mounted) return; // ✅ Prevents context error

                              switch (agentId) {
                                case 1:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SpendingAgentScreen(agentName: advisor['name']),
                                    ),
                                  );
                                  break;
                                case 2:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SavingsAgentScreen(agentName: advisor['name']),
                                    ),
                                  );
                                  break;
                                case 3:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InvestmentAgentScreen(agentName: advisor['name']),
                                    ),
                                  );
                                  break;
                                case 4:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewsAgentScreen(agentName: advisor['name']),
                                    ),
                                  );
                                  break;
                                case 5:
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResearchAgentScreen(agentName: advisor['name']),
                                    ),
                                  );
                                    break;
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              side: BorderSide(color: advisor['color']!, width: 2),
                            ),
                            child: const Text(
                              'Chọn',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ✅ Floating Action Button for Opening Onboarding
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        },
        child: const Icon(Icons.settings, color: Colors.black),
      ),
    );
  }
}
