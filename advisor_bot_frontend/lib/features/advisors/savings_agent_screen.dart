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
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();

  double _desiredReturnRate = 0.05; // 5% as default

  bool _isLoading = false;

  // Results
  String _allocationResult = "";
  String _monthlySavingText = "";
  String _aiAdvice = "";

  Future<void> _generateSavingsPlan() async {
    final String goalName = _goalNameController.text.trim();
    final double? goalAmount = double.tryParse(_goalAmountController.text);
    final int? months = int.tryParse(_monthsController.text);

    if (goalName.isEmpty || goalAmount == null || goalAmount <= 0 || months == null || months <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin (Mục tiêu, Số tiền, Số tháng).")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _monthlySavingText = "";
      _allocationResult = "";
      _aiAdvice = "";
    });

    const String baseUrl = "http://127.0.0.1:8000";
    final Uri apiUrl = Uri.parse("$baseUrl/api/savings");

    // Build request
    final requestBody = {
      "goal_name": goalName,
      "goal_amount": goalAmount,
      "months": months,
      "desired_return_rate": _desiredReturnRate, 
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _monthlySavingText = 
              "Mỗi tháng cần tiết kiệm khoảng ${data["monthly_savings"]} VNĐ";
          _allocationResult = 
              "Phân bổ danh mục: ${data["portfolio_allocation"]}";
          _aiAdvice = data["ai_advice"] ?? "";
        });
      } else {
        setState(() {
          _monthlySavingText = "Lỗi máy chủ: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _monthlySavingText = "Lỗi kết nối: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            // Goal Name
            const Text(
              "Tên Mục Tiêu:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _goalNameController,
              decoration: const InputDecoration(
                hintText: "Ví dụ: Mua xe hơi, Quỹ đám cưới...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Goal Amount
            const Text(
              "Số Tiền Mục Tiêu (VNĐ):",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _goalAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Nhập số tiền muốn tiết kiệm",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Months
            const Text(
              "Số Tháng Dự Kiến:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _monthsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Nhập số tháng",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Desired Return Rate
            const Text(
              "Mức Lợi Suất Mong Muốn (%/năm):",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _desiredReturnRate,
              min: 0.0,
              max: 0.20,
              divisions: 20,
              label: "${(_desiredReturnRate * 100).toStringAsFixed(1)}%",
              onChanged: (val) {
                setState(() => _desiredReturnRate = val);
              },
            ),
            Text("Hiện tại: ${( _desiredReturnRate * 100 ).toStringAsFixed(1)}% / năm"),

            const SizedBox(height: 16),

            // Generate Plan Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateSavingsPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Xem Kế Hoạch", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),

            // Results
            if (_monthlySavingText.isNotEmpty)
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
                    Text(_monthlySavingText, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    if (_allocationResult.isNotEmpty)
                      Text(_allocationResult, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    if (_aiAdvice.isNotEmpty)
                      Text("Lời khuyên AI:\n$_aiAdvice", style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
