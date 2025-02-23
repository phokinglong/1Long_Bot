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
  final List<String> _typeOptions = ['Income', 'Expense'];
  String _selectedType = 'Income';

  final Map<String, List<Map<String, dynamic>>> _categoryMap = {
    'Income': [
      {"name": "Salary", "icon": Icons.monetization_on},
      {"name": "Side Hustle", "icon": Icons.work},
      {"name": "Passive Income", "icon": Icons.account_balance},
    ],
    'Expense': [
      {"name": "Rent", "icon": Icons.home},
      {"name": "Groceries", "icon": Icons.shopping_cart},
      {"name": "Transportation", "icon": Icons.directions_car},
      {"name": "Eating Out", "icon": Icons.restaurant},
      {"name": "Shopping", "icon": Icons.shopping_bag},
      {"name": "Entertainment", "icon": Icons.movie},
      {"name": "Savings", "icon": Icons.savings},
      {"name": "Investments", "icon": Icons.trending_up},
      {"name": "Debt Payments", "icon": Icons.credit_card},
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
        const SnackBar(content: Text("Please enter a valid category and amount.")),
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
        _planResult = "Please add at least one income or expense.";
      });
      return;
    }

    final double monthlyIncome = _items
        .where((item) => item["type"] == "Income")
        .fold(0.0, (sum, item) => sum + (item["amount"] as double));

    final expenses = _items
        .where((item) => item["type"] == "Expense")
        .map((item) => {"category": item["category"], "amount": item["amount"]})
        .toList();

    if (monthlyIncome <= 0) {
      setState(() {
        _planResult = "Please add at least one valid income.";
      });
      return;
    }

    if (expenses.isEmpty) {
      setState(() {
        _planResult = "Please add at least one expense.";
      });
      return;
    }

    const String baseUrl = "http://127.0.0.1:8000";
    final Uri apiUrl = Uri.parse("$baseUrl/api/spending");

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"monthly_income": monthlyIncome, "expenses": expenses}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _planResult = data["plan"] ?? "No plan returned.";
          _suggestedPrompts = List<String>.from(data["suggested_prompts"] ?? []);
        });
      } else {
        setState(() {
          _planResult = "Server error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _planResult = "Connection error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Standardized to lighter theme
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
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    dropdownColor: Colors.white, // ✅ Light mode friendly
                    style: const TextStyle(color: Colors.black), // ✅ Better contrast
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
                      labelText: "Type",
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
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text("Add", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_items.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    leading: Icon(item["type"] == "Income" ? Icons.monetization_on : Icons.receipt_long),
                    title: Text("${item["type"]}: ${item["category"]}", style: const TextStyle(color: Colors.black)),
                    subtitle: Text("\$${item["amount"]}", style: const TextStyle(color: Colors.black87)),
                    trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removeItem(index)),
                  );
                },
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getSpendingPlan,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Get My Budget Plan", style: TextStyle(color: Colors.white)),
            ),
            if (_planResult.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(_planResult, style: const TextStyle(color: Colors.black)),
              ),
          ],
        ),
      ),
    );
  }
}
