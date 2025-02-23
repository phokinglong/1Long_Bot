import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SavingsAgentScreen extends StatefulWidget {
  final String agentName;
  const SavingsAgentScreen({Key? key, required this.agentName}) : super(key: key);

  @override
  _SavingsAgentScreenState createState() => _SavingsAgentScreenState();
}

class _SavingsAgentScreenState extends State<SavingsAgentScreen> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  String _savingsPlan = "";
  String _motivationalTips = "";
  bool _isLoading = false; // ✅ Added loading state

  /// ✅ **Fetch savings plan from backend**
  Future<void> _generateSavingsPlan() async {
    final double? goalAmount = double.tryParse(_goalController.text);
    final int? months = int.tryParse(_monthsController.text);

    if (goalAmount == null || goalAmount <= 0 || months == null || months <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid goal amount and duration.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _savingsPlan = "";
      _motivationalTips = "";
    });

    const String baseUrl = "http://127.0.0.1:8000";
    final Uri apiUrl = Uri.parse("$baseUrl/api/savings");

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"goal_amount": goalAmount, "months": months}), // ✅ Fixed payload
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _savingsPlan = "Save \${data['monthly_savings'].toStringAsFixed(2)} USD per month.";
          _motivationalTips = data["motivational_tips"] ?? "Stay consistent and reach your goal!";
        });
      } else {
        setState(() {
          _savingsPlan = "Server error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _savingsPlan = "Network error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Standardized light theme
      appBar: AppBar(
        title: Text(widget.agentName, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Savings Goal Amount:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter goal amount in USD",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Duration (months):",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _monthsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter duration in months",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isLoading ? null : _generateSavingsPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white) // ✅ Show loading
                  : const Text("Generate Plan", style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 16),

            if (_savingsPlan.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "**Savings Plan:**",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(_savingsPlan, style: const TextStyle(fontSize: 16)),

                    const SizedBox(height: 8),

                    Text(
                      "**Motivational Tips:**",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(_motivationalTips, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
