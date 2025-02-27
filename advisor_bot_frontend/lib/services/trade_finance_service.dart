import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:advisor_bot/models/trade_finance_model.dart';

class TradeFinanceService {
  final String baseUrl = "http://127.0.0.1:8000/trade-finance";

  /// Get advanced trade finance advice
  /// [hideCOT] - if true, chain_of_thought will be hidden
  Future<TradeFinanceAdvancedOutput> getAdvancedTradeFinanceAdvice(
    TradeFinanceInput inputData, 
    { bool hideCOT = false }
  ) async {
    final uri = Uri.parse('$baseUrl/advice-advanced?hide_cot=$hideCOT');
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(inputData.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TradeFinanceAdvancedOutput.fromJson(data);
    } else {
      throw Exception("Failed to get advice: ${response.body}");
    }
  }

  /// Upload a document for the specified query
  Future<void> uploadDocument(int queryId, String filePath) async {
    final request = http.MultipartRequest("POST", Uri.parse("$baseUrl/upload-doc/$queryId"));
    request.files.add(await http.MultipartFile.fromPath("file", filePath));
    final streamedResponse = await request.send();
    final respStr = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode != 200) {
      throw Exception("Failed to upload document: $respStr");
    }
  }
}
