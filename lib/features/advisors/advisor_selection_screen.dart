import 'package:flutter/material.dart';
import 'package:advisor_bot/features/chatbot/chatbot_screen.dart';

class AdvisorSelectionScreen extends StatelessWidget {
  const AdvisorSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> advisors = [
      {
        'name': 'The Conservative Guardian',
        'description': 'A cautious strategist focused on safe investments.',
        'icon': Icons.shield,
        'color': Colors.blue
      },
      {
        'name': 'The Growth Maximizer',
        'description': 'An aggressive investor seeking high returns.',
        'icon': Icons.trending_up,
        'color': Colors.green
      },
      {
        'name': 'The Balanced Mentor',
        'description': 'A patient guide balancing risk and reward.',
        'icon': Icons.balance,
        'color': Colors.orange
      },
      {
        'name': 'The Crypto Visionary',
        'description': 'A blockchain expert focused on crypto and Web3.',
        'icon': Icons.currency_bitcoin,
        'color': Colors.purple
      },
      {
        'name': 'FAQ Bot',
        'description': 'Learn more about financial strategies before choosing an advisor.',
        'icon': Icons.help_outline,
        'color': Colors.grey
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2), // 1Long's background color
      appBar: AppBar(
        title: const Text(
          'Select Your AI Financial Advisor',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: advisors.map((advisor) {
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: advisor['color'].withOpacity(0.2),
                  child: Icon(advisor['icon'], color: advisor['color']),
                ),
                title: Text(
                  advisor['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(advisor['description']),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatbotScreen(advisorName: advisor['name']),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: advisor['color'],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Select', style: TextStyle(color: Colors.white)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
