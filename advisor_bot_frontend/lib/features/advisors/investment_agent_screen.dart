import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InvestmentAgentScreen extends StatefulWidget {
  final String agentName;

  const InvestmentAgentScreen({super.key, required this.agentName});

  @override
  _InvestmentAgentScreenState createState() => _InvestmentAgentScreenState();
}

class _InvestmentAgentScreenState extends State<InvestmentAgentScreen> {
  final TextEditingController _investmentController = TextEditingController();
  String _selectedRiskTolerance = "medium";
  String _investmentPlan = "";

  final List<String> _riskLevels = ["low", "medium", "high"];

  Future<void> _getInvestmentPlan() async {
    final double? investment = double.tryParse(_investmentController.text);

    if (investment == null || investment <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid investment amount.")),
      );
      return;
    }

    const String baseUrl = "http://127.0.0.1:8000";
    final Uri apiUrl = Uri.parse("$baseUrl/api/investment");

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "initial_investment": investment,
          "risk_tolerance": _selectedRiskTolerance,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _investmentPlan = data["plan"] ?? "No investment plan returned.";
        });
      } else {
        setState(() {
          _investmentPlan = "Error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _investmentPlan = "Connection error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Updated to match lighter UI
      appBar: AppBar(
        title: Text(widget.agentName, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView( // ✅ Fixes overflow issue
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Initial Investment Amount:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _investmentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Select Risk Tolerance:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              value: _selectedRiskTolerance,
              items: _riskLevels.map((risk) {
                return DropdownMenuItem<String>(
                  value: risk,
                  child: Text(risk.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedRiskTolerance = val;
                  });
                }
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _getInvestmentPlan,
              child: const Text("Get Investment Plan"),
            ),

            const SizedBox(height: 16),

            if (_investmentPlan.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _investmentPlan,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
