import 'package:flutter/material.dart';

class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  OnboardingFormState createState() => OnboardingFormState();
}

class OnboardingFormState extends State<OnboardingForm> {
  String investingExperience = "Beginner";
  String financialGoal = "Wealth Growth";
  String netWorth = "100M - 500M VND";
  bool personalizedAdvice = false;
  String riskTolerance = "Moderate";
  final List<String> selectedInvestments = [];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildDropdown("Your investing experience", investingExperience,
            ["Beginner", "Intermediate", "Advanced"], (value) {
          setState(() {
            investingExperience = value!;
          });
        }),

        _buildDropdown("Your primary financial goal", financialGoal,
            ["Wealth Growth", "Retirement", "Stable Income"], (value) {
          setState(() {
            financialGoal = value!;
          });
        }),

        _buildDropdown("Your estimated net worth (VND)", netWorth,
            ["100M - 500M VND", "500M - 1B VND", "1B+ VND"], (value) {
          setState(() {
            netWorth = value!;
          });
        }),

        _buildMultiSelect("Preferred Investment Types", [
          "Stocks",
          "Bonds",
          "Real Estate",
          "Crypto",
          "Mutual Funds",
          "Private Equity"
        ]),

        _buildToggle(
            "Do you want personalized financial advisory services?",
            personalizedAdvice, (value) {
          setState(() {
            personalizedAdvice = value;
          });
        }),

        _buildDropdown("Your risk tolerance", riskTolerance,
            ["Low", "Moderate", "High"], (value) {
          setState(() {
            riskTolerance = value!;
          });
        }),

        _buildTextField("Estate Planning Strategy (if any)"),
        _buildTextField("Tax Planning Strategy (if any)"),
        _buildTextField("How do you diversify your portfolio?"),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
          items: options
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMultiSelect(String label, List<String> options) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
