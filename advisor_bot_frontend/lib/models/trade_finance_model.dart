class TradeFinanceInput {
  final String originCountry;
  final String destinationCountry;
  final String commodityDescription;
  final double invoiceAmount;
  final String? task; // ✅ Add this line


  TradeFinanceInput({
    required this.originCountry,
    required this.destinationCountry,
    required this.commodityDescription,
    required this.invoiceAmount,
    this.task, // ✅ Ensure this is here

  });

  Map<String, dynamic> toJson() => {
    'origin_country': originCountry,
    'destination_country': destinationCountry,
    'commodity_description': commodityDescription,
    'invoice_amount': invoiceAmount,
    "task": task, // ✅ Include in JSON conversion
  };
}

class FinancingOptionModel {
  final String optionType;
  final double interestRate;
  final bool collateralRequired;
  final String? notes;

  FinancingOptionModel({
    required this.optionType,
    required this.interestRate,
    required this.collateralRequired,
    this.notes,
  });

  factory FinancingOptionModel.fromJson(Map<String, dynamic> json) {
    return FinancingOptionModel(
      optionType: json['option_type'],
      interestRate: (json['interest_rate'] as num).toDouble(),
      collateralRequired: json['collateral_required'],
      notes: json['notes'],
    );
  }
}

class TradeFinanceOutput {
  final String originCountry;
  final String destinationCountry;
  final String commodityDescription;
  final double invoiceAmount;
  final List<FinancingOptionModel> recommendedOptions;
  final String overallRecommendation;

  TradeFinanceOutput({
    required this.originCountry,
    required this.destinationCountry,
    required this.commodityDescription,
    required this.invoiceAmount,
    required this.recommendedOptions,
    required this.overallRecommendation,
  });

  factory TradeFinanceOutput.fromJson(Map<String, dynamic> json) {
    final recOptionsJson = json['recommended_options'] as List<dynamic>?;
    final recommendedOptions = recOptionsJson != null
      ? recOptionsJson.map((e) => FinancingOptionModel.fromJson(e)).toList()
      : <FinancingOptionModel>[];

    return TradeFinanceOutput(
      originCountry: json['origin_country'],
      destinationCountry: json['destination_country'],
      commodityDescription: json['commodity_description'],
      invoiceAmount: (json['invoice_amount'] as num).toDouble(),
      recommendedOptions: recommendedOptions,
      overallRecommendation: json['overall_recommendation'],
    );
  }
}

class TradeFinanceAdvancedOutput {
  final int queryId;
  final String originCountry;
  final String destinationCountry;
  final String commodityDescription;
  final double invoiceAmount;
  final String? task;
  final String finalRecommendation;
  final String? chainOfThought;
  final List<String> documents;
  final String? generatedDoc; // ✅ Add this property


  TradeFinanceAdvancedOutput({
    required this.queryId,
    required this.originCountry,
    required this.destinationCountry,
    required this.commodityDescription,
    required this.invoiceAmount,
    required this.finalRecommendation,
    this.task,
    this.chainOfThought,
    this.documents = const [],
    this.generatedDoc, // ✅ Make sure it's in the constructor
  });

  factory TradeFinanceAdvancedOutput.fromJson(Map<String, dynamic> json) {
    return TradeFinanceAdvancedOutput(
      queryId: json['query_id'],
      originCountry: json['origin_country'],
      destinationCountry: json['destination_country'],
      commodityDescription: json['commodity_description'],
      invoiceAmount: json['invoice_amount'].toDouble(),
      task: json['task'],
      finalRecommendation: json['final_recommendation'],
      chainOfThought: json['chain_of_thought'],
      documents: List<String>.from(json['documents'] ?? []),
      generatedDoc: json['generated_doc'], // ✅ Parse from JSON 
    );
  }
}
