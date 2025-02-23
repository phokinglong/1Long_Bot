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

  String _monthlySavingText = "";
  String _motivationalTips = "";
  bool _isLoading = false;

  Future<void> _generateSavingsPlan() async {
    final double? goalAmount = double.tryParse(_goalController.text);
    final int? months = int.tryParse(_monthsController.text);

    if (goalAmount == null || goalAmount <= 0 || months == null || months <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập số tiền mục tiêu và số tháng hợp lệ.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _monthlySavingText = "";
      _motivationalTips = "";
    });

    const String baseUrl = "http://127.0.0.1:8000";
    final Uri apiUrl = Uri.parse("$baseUrl/api/savings");

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "goal_amount": goalAmount,
          "months": months,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Convert to a more readable format (VNĐ)
        double monthlySavings = data["monthly_savings"]?.toDouble() ?? 0;
        String tips = data["motivational_tips"] ?? "Hãy kiên trì để đạt mục tiêu!";

        setState(() {
          _monthlySavingText =
              "Mỗi tháng nên tiết kiệm: ${monthlySavings.toStringAsFixed(0)} VNĐ.";
          _motivationalTips = tips;
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Giao diện sáng
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
              "Số Tiền Mục Tiêu (VNĐ):",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Nhập số tiền bạn muốn tiết kiệm",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Số Tháng Dự Kiến:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

            // Nút Lấy Kế Hoạch
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateSavingsPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Xem Kế Hoạch Tiết Kiệm", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // Kết quả
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
                    const Text(
                      "Kế Hoạch Tiết Kiệm:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(_monthlySavingText, style: const TextStyle(fontSize: 16)),

                    const SizedBox(height: 8),

                    const Text(
                      "Lời Khuyên Khích Lệ:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _motivationalTips,
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
