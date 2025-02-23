import 'package:flutter/material.dart';
import 'package:advisor_bot/features/onboarding/onboarding_controller.dart';

class OnboardingForm extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingForm({super.key, required this.onComplete});

  @override
  OnboardingFormState createState() => OnboardingFormState();
}

class OnboardingFormState extends State<OnboardingForm> {
  final _formKey = GlobalKey<FormState>();

  String investingExperience = "Beginner";
  String financialGoal = "Wealth Growth";
  String netWorth = "100M - 500M VND";
  bool personalizedAdvice = false;
  String riskTolerance = "Moderate";
  final List<String> selectedInvestments = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await OnboardingController.getUserData();
    setState(() {
      investingExperience = userData['experienceLevel'] ?? investingExperience;
      financialGoal = userData['goal'] ?? financialGoal;
    });
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    await OnboardingController.saveUserData(
      name: "User",
      experienceLevel: investingExperience,
      goal: financialGoal,
    );

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown(
              "Kinh nghiệm đầu tư",
              investingExperience,
              ["Beginner", "Intermediate", "Advanced"],
              (value) => setState(() => investingExperience = value!),
            ),

            _buildDropdown(
              "Mục tiêu tài chính chính",
              financialGoal,
              ["Wealth Growth", "Retirement", "Stable Income"],
              (value) => setState(() => financialGoal = value!),
            ),

            _buildDropdown(
              "Tài sản ròng ước tính (VND)",
              netWorth,
              ["100M - 500M VND", "500M - 1B VND", "1B+ VND"],
              (value) => setState(() => netWorth = value!),
            ),

            _buildMultiSelect("Loại đầu tư ưu tiên", [
              "Cổ phiếu",
              "Trái phiếu",
              "Bất động sản",
              "Crypto",
              "Quỹ đầu tư",
              "Vốn tư nhân"
            ]),

            _buildToggle(
              "Bạn có muốn tư vấn tài chính cá nhân không?",
              personalizedAdvice,
              (value) => setState(() => personalizedAdvice = value),
            ),

            _buildDropdown(
              "Khả năng chấp nhận rủi ro",
              riskTolerance,
              ["Thấp", "Trung bình", "Cao"],
              (value) => setState(() => riskTolerance = value!),
            ),

            _buildTextField("Chiến lược kế hoạch bất động sản (nếu có)"),
            _buildTextField("Chiến lược thuế (nếu có)"),
            _buildTextField("Làm thế nào để đa dạng hóa danh mục của bạn?"),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Tiếp tục", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: options.contains(value) ? value : options.first,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMultiSelect(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: options.map((option) {
              final isSelected = selectedInvestments.contains(option);
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedInvestments.add(option);
                    } else {
                      selectedInvestments.remove(option);
                    }
                  });
                },
                selectedColor: Colors.black,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.black,
    );
  }

  Widget _buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}
