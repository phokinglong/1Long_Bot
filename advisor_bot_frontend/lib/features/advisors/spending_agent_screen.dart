import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SpendingAgentScreen extends StatefulWidget {
  final String agentName;
  const SpendingAgentScreen({Key? key, required this.agentName}) : super(key: key);

  @override
  _SpendingAgentScreenState createState() => _SpendingAgentScreenState();
}

class _SpendingAgentScreenState extends State<SpendingAgentScreen> {
  final List<Map<String, dynamic>> _items = [];

  // Đổi sang tiếng Việt
  final List<String> _typeOptions = ['Thu nhập', 'Chi tiêu'];
  String _selectedType = 'Thu nhập';

  final Map<String, List<Map<String, dynamic>>> _categoryMap = {
    'Thu nhập': [
      {"name": "Lương", "icon": Icons.monetization_on},
      {"name": "Việc phụ", "icon": Icons.work},
      {"name": "Thu nhập thụ động", "icon": Icons.account_balance},
    ],
    'Chi tiêu': [
      {"name": "Thuê nhà", "icon": Icons.home},
      {"name": "Đi chợ", "icon": Icons.shopping_cart},
      {"name": "Đi lại", "icon": Icons.directions_car},
      {"name": "Ăn ngoài", "icon": Icons.restaurant},
      {"name": "Mua sắm", "icon": Icons.shopping_bag},
      {"name": "Giải trí", "icon": Icons.movie},
      {"name": "Tiết kiệm", "icon": Icons.savings},
      {"name": "Đầu tư", "icon": Icons.trending_up},
      {"name": "Trả nợ", "icon": Icons.credit_card},
    ],
  };

  late String _selectedCategory;
  final TextEditingController _amountController = TextEditingController();

  String _planResult = '';
  List<String> _suggestedPrompts = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categoryMap[_selectedType]!.first["name"];
  }

  void _addItem() {
    final double? amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0 || _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập hạng mục và số tiền hợp lệ.")),
      );
      return;
    }

    setState(() {
      _items.add({
        "type": _selectedType,
        "category": _selectedCategory,
        "amount": amount,
      });
    });

    _amountController.clear();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _getSpendingPlan() async {
    if (_items.isEmpty) {
      setState(() {
        _planResult = "Vui lòng thêm ít nhất một khoản Thu nhập hoặc Chi tiêu.";
      });
      return;
    }

    // Tính tổng Thu nhập
    final double monthlyIncome = _items
        .where((item) => item["type"] == "Thu nhập")
        .fold(0.0, (sum, item) => sum + (item["amount"] as double));

    // Tập hợp tất cả các khoản Chi tiêu
    final expenses = _items
        .where((item) => item["type"] == "Chi tiêu")
        .map((item) => {
          "category": item["category"],
          "amount": item["amount"],
        })
        .toList();

    if (monthlyIncome <= 0) {
      setState(() {
        _planResult = "Cần ít nhất một khoản Thu nhập hợp lệ.";
      });
      return;
    }
    if (expenses.isEmpty) {
      setState(() {
        _planResult = "Vui lòng thêm ít nhất một khoản Chi tiêu.";
      });
      return;
    }

    const String baseUrl = "http://127.0.0.1:8000";
    final Uri apiUrl = Uri.parse("$baseUrl/api/spending");

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "monthly_income": monthlyIncome,
          "expenses": expenses,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _planResult = data["plan"] ?? "Không nhận được kế hoạch từ AI.";
          _suggestedPrompts = List<String>.from(data["suggested_prompts"] ?? []);
        });
      } else {
        setState(() {
          _planResult = "Lỗi máy chủ: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _planResult = "Lỗi kết nối: $e";
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown chọn loại (Thu nhập/Chi tiêu) + Hạng mục
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black),
                    items: _typeOptions.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedType = val;
                          _selectedCategory = _categoryMap[_selectedType]!.first["name"];
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Loại",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black),
                    items: _categoryMap[_selectedType]!
                        .map((cat) => DropdownMenuItem<String>(
                              value: cat["name"],
                              child: Text(cat["name"]),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Hạng mục",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nhập số tiền + nút Thêm
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Số tiền (VNĐ)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text("Thêm", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Danh sách các khoản
            if (_items.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    leading: Icon(
                      item["type"] == "Thu nhập"
                          ? Icons.monetization_on
                          : Icons.receipt_long
                    ),
                    title: Text(
                      "${item["type"]}: ${item["category"]}",
                      style: const TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      "${item["amount"]} VNĐ",
                      style: const TextStyle(color: Colors.black87),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeItem(index),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),

            // Nút lấy Kế hoạch chi tiêu
            ElevatedButton(
              onPressed: _getSpendingPlan,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text(
                "Xem Kế Hoạch Chi Tiêu",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Hiển thị kết quả AI
            if (_planResult.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _planResult,
                  style: const TextStyle(color: Colors.black),
                ),
              ),

            // Các gợi ý prompts (nếu có)
            if (_suggestedPrompts.isNotEmpty) ...[
              const Divider(),
              ..._suggestedPrompts.map((prompt) => ListTile(title: Text(prompt))),
            ],
          ],
        ),
      ),
    );
  }
}
