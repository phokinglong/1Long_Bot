import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';  // for opening links

class NewsAgentScreen extends StatefulWidget {
  final String agentName;
  const NewsAgentScreen({Key? key, required this.agentName}) : super(key: key);

  @override
  _NewsAgentScreenState createState() => _NewsAgentScreenState();
}

class _NewsAgentScreenState extends State<NewsAgentScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _analysisText = "";
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = false;

  Future<void> _fetchNews() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập chủ đề.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisText = "";
      _articles.clear();
    });

    const baseUrl = "http://127.0.0.1:8000";
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
          _analysisText = data["analysis"] ?? "Không có phân tích.";
          final articlesRaw = data["articles"] ?? [];
          _articles = List<Map<String, dynamic>>.from(articlesRaw);
        });
      } else {
        setState(() {
          _analysisText = "Lỗi lấy tin tức: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _analysisText = "Lỗi kết nối: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Attempt to open a URL in external browser
  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể mở link: $url")),
      );
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
              "Nhập từ khóa hoặc chủ đề tin tức tài chính:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                hintText: "Ví dụ: cổ phiếu, tên công ty, ...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isLoading ? null : _fetchNews,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Tìm Tin Tức", style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 16),

            if (_analysisText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _analysisText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

            if (_articles.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "Các Bài Viết Liên Quan:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                itemCount: _articles.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  final title = article["title"] ?? "No title";
                  final url = article["url"] ?? "#";

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(title, style: const TextStyle(color: Colors.blue)),
                    subtitle: Text(url, style: const TextStyle(color: Colors.grey)),
                    onTap: () => _openLink(url),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
