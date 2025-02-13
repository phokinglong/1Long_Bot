import 'package:flutter/material.dart';
import 'package:advisor_bot/services/openai_service.dart';

class ChatbotScreen extends StatefulWidget {
  final String advisorName;

  const ChatbotScreen({super.key, required this.advisorName});

  @override
  ChatbotScreenState createState() => ChatbotScreenState();
}

class ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Suggested prompts mapped to each advisor
  final Map<String, List<String>> _suggestedPrompts = {
    "The Conservative Guardian": [
      "What are safe ways to invest my portfolio?",
      "How should I think about risk and return?",
      "How to hedge a portfolio against market volatility?",
      "Is it okay to keep my money in a bank only?",
      "What is the purpose of gold?",
    ],
    "The Growth Maximizer": [
      "What is a good return on my investment yearly?",
      "What are some of the best-performing asset classes recently?",
      "How much should I allocate into stocks?",
      "What is margin and how should I use it?",
      "What are options and how do they work?",
    ],
    "The Balanced Mentor": [
      "How to balance my portfolio?",
      "Suggest allocation for each asset class",
      "Teach me about all the available assets",
      "Is real estate a good option?",
    ],
    "The Crypto Visionary": [
      "What is crypto?",
      "Why is crypto popular?",
      "What is the purpose of Bitcoin?",
      "Show me how to research opportunities in crypto?",
    ],
    "FAQ Bot": [
      "What is 1Long?",
      "What is 1Equity?",
      "What is 1Safe, 1Term, 1Income?",
      "Is 1Long safe?",
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

    String response =
        await OpenAIService.getAIResponse(widget.advisorName, userId, text);

    setState(() {
      _messages.add({'role': 'bot', 'text': response});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> prompts = _suggestedPrompts[widget.advisorName] ?? [];

    return Scaffold(
      backgroundColor: Color(0xFFF7F5F2), // Soft background
      appBar: AppBar(
        title: Text(
          widget.advisorName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message['role'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(12),
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
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser ? Colors.black : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(),
            ),

          // Suggested Prompts Carousel
          if (prompts.isNotEmpty)
            Container(
              height: 80,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: prompts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _sendMessage(prompts[index]),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          prompts[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask a question...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
