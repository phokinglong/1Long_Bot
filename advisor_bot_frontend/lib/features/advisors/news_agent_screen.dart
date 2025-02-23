import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewsAgentScreen extends StatefulWidget {
  final String agentName;
  const NewsAgentScreen({Key? key, required this.agentName}) : super(key: key);

  @override
  _NewsAgentScreenState createState() => _NewsAgentScreenState();
}

class _NewsAgentScreenState extends State<NewsAgentScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _newsSummary = "";
  bool _isLoading = false;

  Future<void> _fetchNews() async {
    final String topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập chủ đề.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    const String baseUrl = "http://127.0.0.1:8000";
    final Uri apiUrl = Uri.parse("$baseUrl/api/news");

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"topic": topic}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _newsSummary = data["analysis"] ?? "Chưa có thông tin về chủ đề này.";
        });
      } else {
        setState(() {
          _newsSummary = "Lỗi lấy tin tức: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _newsSummary = "Lỗi kết nối: $e";
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nhập chủ đề tin tức tài chính:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                hintText: "Ví dụ: cổ phiếu, tiền ảo, lạm phát...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _fetchNews,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Xem Tin Tức Mới Nhất", style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 16),

            if (_isLoading) const Center(child: CircularProgressIndicator()),

            if (_newsSummary.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _newsSummary,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
