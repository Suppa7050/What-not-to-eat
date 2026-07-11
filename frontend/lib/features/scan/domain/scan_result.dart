import 'package:json_annotation/json_annotation.dart';

part 'scan_result.g.dart';

@JsonSerializable()
class ScanResult {
  final String productName;
  final int overallHealthScore;
  final String overallIndicator;
  final String summary;
  final List<String> goodIngredients;
  final List<String> neutralIngredients;
  final List<IngredientDetail> badIngredients;
  final List<String> warnings;
  final List<String> healthBenefits;
  final List<String> healthRisks;
  final List<String>? recommendedFor;
  final List<String>? notRecommendedFor;
  final String disclaimer;

  ScanResult({
    required this.productName,
    required this.overallHealthScore,
    required this.overallIndicator,
    required this.summary,
    required this.goodIngredients,
    required this.neutralIngredients,
    required this.badIngredients,
    required this.warnings,
    required this.healthBenefits,
    required this.healthRisks,
    this.recommendedFor,
    this.notRecommendedFor,
    required this.disclaimer,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) => _$ScanResultFromJson(json);
  Map<String, dynamic> toJson() => _$ScanResultToJson(this);
}

@JsonSerializable()
class IngredientDetail {
  final String ingredient;
  final String category;
  final int healthScore;
  final String indicator;
  final bool avoid;
  final String reason;
  final String details;

  IngredientDetail({
    required this.ingredient,
    required this.category,
    required this.healthScore,
    required this.indicator,
    required this.avoid,
    required this.reason,
    required this.details,
  });

  factory IngredientDetail.fromJson(Map<String, dynamic> json) => _$IngredientDetailFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientDetailToJson(this);
}
