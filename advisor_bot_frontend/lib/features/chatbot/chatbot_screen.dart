import 'package:flutter/material.dart';
import 'package:advisor_bot/services/openai_service.dart';

class ChatbotScreen extends StatefulWidget {
  final String agentName;

  const ChatbotScreen({super.key, required this.agentName});

  @override
  ChatbotScreenState createState() => ChatbotScreenState();
}

class ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Suggested prompts mapped to each agent
  final Map<String, List<String>> _suggestedPrompts = {
    "Cộng sự Chi tiêu": [
      "How can I optimize my monthly budget?",
      "What are common expense categories?",
      "How much should I allocate to savings?",
      "How do I cut down on unnecessary spending?",
    ],
    "Cộng sự Tích lũy": [
      "How much should I save each month?",
      "What are the best ways to grow savings?",
      "How do I plan for a big financial goal?",
      "What are some high-interest savings accounts?",
    ],
    "Cộng sự Đầu tư": [
      "How do I start investing?",
      "What’s a good asset allocation strategy?",
      "What are the risks in stock market investing?",
      "How can I build a diversified portfolio?",
    ],
    "Cộng sự Tin tức": [
      "What are today’s financial headlines?",
      "Can you analyze recent market trends?",
      "How does inflation affect my investments?",
      "What should I know about cryptocurrency today?",
    ],
  };

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });

    // Placeholder User ID
    String userId = "user123";

    String response = await OpenAIService.getAIResponse(widget.agentName,{"question": text} // Convert text into a Map<String, dynamic>
    );

    setState(() {
      _messages.add({'role': 'bot', 'text': response});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> prompts = _suggestedPrompts[widget.agentName] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      appBar: AppBar(
        title: Text(
          widget.agentName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message['role'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[200] : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Text(
                      message['text']!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(),
            ),

          if (prompts.isNotEmpty)
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: prompts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _sendMessage(prompts[index]),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          prompts[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Input Box
          _buildInputBox(),
        ],
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Ask a question...")),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}
