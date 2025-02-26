import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResearchAgentScreen extends StatefulWidget {
  final String agentName;

  const ResearchAgentScreen({Key? key, required this.agentName}) : super(key: key);

  @override
  _ResearchAgentScreenState createState() => _ResearchAgentScreenState();
}

class _ResearchAgentScreenState extends State<ResearchAgentScreen> {
  final TextEditingController _stockSymbolController = TextEditingController();
  
  // Let's have a set of possible metrics
  final List<String> possibleMetrics = [
    "income_statement",
    "cash_flow",
    "balance_sheet",
    "financial_summary",
  ];
  // Keep track of which metrics user selected
  final List<String> selectedMetrics = [];

  String _analysisResult = "";
  bool _isLoading = false;

  Future<void> _sendResearchRequest() async {
    final symbol = _stockSymbolController.text.trim();
    if (symbol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập mã cổ phiếu!")),
      );
      return;
    }
    if (selectedMetrics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn ít nhất một chỉ số.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = "";
    });

    const String baseUrl = "http://127.0.0.1:8000";
    final Uri apiUrl = Uri.parse("$baseUrl/api/research");

    final requestBody = {
      "stock_symbol": symbol,
      "metrics": selectedMetrics.map((m) => {"metric_name": m}).toList(),
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
          _analysisResult = data["analysis"] ?? "Không có kết quả phân tích.";
        });
      } else {
        setState(() {
          _analysisResult = "Lỗi máy chủ: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _analysisResult = "Lỗi kết nối: $e";
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.agentName, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nhập mã cổ phiếu (VN):",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _stockSymbolController,
              decoration: const InputDecoration(
                hintText: "Ví dụ: VCB, HPG, VIC...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Chọn các chỉ số muốn xem:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: possibleMetrics.map((metric) {
                final isSelected = selectedMetrics.contains(metric);
                return ChoiceChip(
                  label: Text(metric),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedMetrics.add(metric);
                      } else {
                        selectedMetrics.remove(metric);
                      }
                    });
                  },
                  selectedColor: Colors.black,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendResearchRequest,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Nghiên cứu", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),

            if (_analysisResult.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _analysisResult,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
