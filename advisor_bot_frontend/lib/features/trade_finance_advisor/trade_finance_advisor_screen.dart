import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TradeFinanceAgentScreen extends StatefulWidget {
  const TradeFinanceAgentScreen({Key? key}) : super(key: key);

  @override
  _TradeFinanceAgentScreenState createState() => _TradeFinanceAgentScreenState();
}

class _TradeFinanceAgentScreenState extends State<TradeFinanceAgentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _commodityCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  int? _selectedPromptId;
  String? _aiResponse;
  String? _combinedPrompt;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final requestBody = {
      "origin_country": _originCtrl.text,
      "destination_country": _destCtrl.text,
      "commodity_description": _commodityCtrl.text,
      "invoice_amount": double.parse(_amountCtrl.text),
      "prompt_id": _selectedPromptId
    };

    try {
      final resp = await http.post(
        Uri.parse("http://127.0.0.1:8000/trade-finance/advice"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          _aiResponse = data["ai_response"];
          _combinedPrompt = data["combined_prompt"];
          _error = null;
        });
      } else {
        setState(() {
          _error = "Error ${resp.statusCode}: ${resp.body}";
          _aiResponse = null;
          _combinedPrompt = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Network error: $e";
        _aiResponse = null;
        _combinedPrompt = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trade Finance AI Agent')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _originCtrl,
                decoration: const InputDecoration(labelText: 'Origin Country'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _destCtrl,
                decoration: const InputDecoration(labelText: 'Destination Country'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _commodityCtrl,
                decoration: const InputDecoration(labelText: 'Commodity Description'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Invoice Amount'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  return double.tryParse(val) == null ? 'Must be numeric' : null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedPromptId,
                decoration: const InputDecoration(labelText: 'Select Use Case'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1 - Risk Analysis')),
                  DropdownMenuItem(value: 2, child: Text('2 - Payment Structure')),
                  DropdownMenuItem(value: 3, child: Text('3 - Sanctions Check')),
                  DropdownMenuItem(value: 4, child: Text('4 - Incoterms Guidance')),
                  DropdownMenuItem(value: 5, child: Text('5 - Insurance Coverage')),
                  DropdownMenuItem(value: 6, child: Text('6 - Freight Forwarding Strategy')),
                  DropdownMenuItem(value: 7, child: Text('7 - Due Diligence')),
                  DropdownMenuItem(value: 8, child: Text('8 - Document Checklist')),
                  DropdownMenuItem(value: 9, child: Text('9 - Optimal Credit Terms')),
                  DropdownMenuItem(value: 10, child: Text('10 - Sustainable Finance Pitch')),
                ],
                onChanged: (val) {
                  setState(() => _selectedPromptId = val);
                },
                validator: (val) => val == null ? 'Please choose a prompt' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Get AI Advice'),
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_combinedPrompt != null) ...[
                const Text("Final Prompt:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_combinedPrompt!),
              ],
              const SizedBox(height: 10),
              if (_aiResponse != null) ...[
                const Text("AI Response:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_aiResponse!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
