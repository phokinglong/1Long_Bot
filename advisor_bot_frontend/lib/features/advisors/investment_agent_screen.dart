import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Helper function to format large numbers into “triệu” or “tỷ”.
String formatVND(double value) {
  if (value >= 1e9) {
    // Từ 1.000.000.000 trở lên => “tỷ”
    double billions = value / 1e9;
    return "${billions.toStringAsFixed(2)} tỷ";
  } else if (value >= 1e6) {
    // Từ 1.000.000 trở lên => “triệu”
    double millions = value / 1e6;
    return "${millions.toStringAsFixed(2)} triệu";
  } else {
    // Dưới 1 triệu => hiển thị số đầy đủ
    return value.toStringAsFixed(0);
  }
}

class InvestmentAgentScreen extends StatefulWidget {
  final String agentName;
  const InvestmentAgentScreen({Key? key, required this.agentName}) : super(key: key);

  @override
  _InvestmentAgentScreenState createState() => _InvestmentAgentScreenState();
}

class _InvestmentAgentScreenState extends State<InvestmentAgentScreen> {
  // Controllers & lists
  final TextEditingController _assetValueController = TextEditingController();

  // Risk tolerance in Vietnamese for UI, mapped to English for the backend
  final List<String> _riskLevelsVN = ["Thấp", "Trung bình", "Cao"];
  final Map<String, String> _riskMap = {
    "Thấp": "low",
    "Trung bình": "medium",
    "Cao": "high",
  };
  String _selectedRiskToleranceVN = "Trung bình";

  // Asset types in Vietnamese for UI, but send English keys to the backend
  final List<String> _assetTypesVN = ["Cổ phiếu", "Bất động sản", "Vàng", "Tiền gửi ngân hàng"];
  final Map<String, String> _assetTypeMap = {
    "Cổ phiếu": "stock",
    "Bất động sản": "real_estate",
    "Vàng": "gold",
    "Tiền gửi ngân hàng": "bank_deposit",
  };
  String _selectedAssetTypeVN = "Cổ phiếu";

  // Assets to be sent to the backend
  final List<Map<String, dynamic>> _assets = [];

  // API response
  double _totalValue = 0.0;
  double _projectedValue = 0.0;
  String _aiRebalanceAdvice = "";
  String _graphBase64 = "";

  bool _isLoading = false;

  // Add an asset to the list
  void _addAsset() {
    final double? assetValue = double.tryParse(_assetValueController.text.trim());
    if (assetValue == null || assetValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập giá trị tài sản hợp lệ.")),
      );
      return;
    }
    setState(() {
      _assets.add({
        "asset_type": _assetTypeMap[_selectedAssetTypeVN], // Convert to English key
        "value": assetValue,
      });
      _assetValueController.clear();
    });
  }

  // Remove an asset
  void _removeAsset(int index) {
    setState(() {
      _assets.removeAt(index);
    });
  }

  // Decode base64 => Image widget
  Widget _buildGraphImage() {
    if (_graphBase64.isEmpty) return Container();
    try {
      Uint8List imageBytes = base64Decode(_graphBase64);
      return Image.memory(imageBytes, fit: BoxFit.contain);
    } catch (e) {
      return const Text("Lỗi hiển thị biểu đồ.");
    }
  }

  // Call the backend to get the investment plan
  Future<void> _getInvestmentPlan() async {
    if (_assets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng thêm ít nhất một tài sản.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _totalValue = 0.0;
      _projectedValue = 0.0;
      _aiRebalanceAdvice = "";
      _graphBase64 = "";
    });

    const String baseUrl = "http://127.0.0.1:8000";
    final Uri apiUrl = Uri.parse("$baseUrl/api/investment");

    // Convert the selected risk tolerance to English for the backend
    final String mappedRisk = _riskMap[_selectedRiskToleranceVN] ?? "medium";

    // Build the request body
    final requestBody = {
      "risk_tolerance": mappedRisk,
      "assets": _assets,
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
          _totalValue = (data["total_value"] ?? 0.0).toDouble();
          _projectedValue = (data["projected_value"] ?? 0.0).toDouble();
          _aiRebalanceAdvice = data["ai_rebalance_advice"] ?? "Không có khuyến nghị.";
          _graphBase64 = data["graph"] ?? "";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi máy chủ: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e")),
      );
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
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Risk tolerance
            const Text(
              "Chọn Mức Độ Rủi Ro:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedRiskToleranceVN,
              items: _riskLevelsVN.map((riskVN) {
                return DropdownMenuItem<String>(
                  value: riskVN,
                  child: Text(riskVN.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedRiskToleranceVN = val;
                  });
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Asset addition
            const Text(
              "Thêm Tài Sản:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedAssetTypeVN,
                    items: _assetTypesVN.map((typeVN) {
                      return DropdownMenuItem<String>(
                        value: typeVN,
                        child: Text(typeVN.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedAssetTypeVN = val;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Loại Tài Sản",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _assetValueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Giá Trị (VNĐ)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addAsset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  child: const Text("Thêm", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Asset list
            if (_assets.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Danh Sách Tài Sản:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _assets.length,
                    itemBuilder: (context, index) {
                      final asset = _assets[index];
                      final typeKey = asset["asset_type"] as String;
                      // Reverse lookup to get the Vietnamese label
                      final typeVN = _assetTypeMap.entries
                          .firstWhere((entry) => entry.value == typeKey)
                          .key;
                      final value = asset["value"] as double;
                      return ListTile(
                        leading: const Icon(Icons.pie_chart),
                        title: Text(
                          "$typeVN: ${formatVND(value)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeAsset(index),
                        ),
                      );
                    },
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Get plan button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _getInvestmentPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Xem Kế Hoạch Đầu Tư", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // Results
            if (_totalValue > 0)
              Text(
                "Tổng Giá Trị Tài Sản: ${formatVND(_totalValue)} VNĐ",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            if (_projectedValue > 0)
              Text(
                "Giá Trị Sau 5 Năm: ${formatVND(_projectedValue)} VNĐ",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

            if (_aiRebalanceAdvice.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: double.infinity, // allow wrapping
                  ),
                  child: Text(
                    "Khuyến Nghị Tái Cân Bằng:\n$_aiRebalanceAdvice",
                    style: const TextStyle(fontSize: 16),
                    softWrap: true, // ensure wrapping
                  ),
                ),
              ),
            const SizedBox(height: 16),

            if (_graphBase64.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Biểu Đồ Tăng Trưởng Tài Sản:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildGraphImage(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
