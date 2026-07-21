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

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      productName: json['productName'] as String? ?? 'Unknown Product',
      overallHealthScore: (json['overallHealthScore'] as num?)?.toInt() ?? 50,
      overallIndicator: json['overallIndicator'] as String? ?? 'YELLOW',
      summary: json['summary'] as String? ?? '',
      goodIngredients: (json['goodIngredients'] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      neutralIngredients: (json['neutralIngredients'] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      badIngredients: (json['badIngredients'] as List<dynamic>?)
              ?.map((e) => IngredientDetail.fromJson(e is Map<String, dynamic> ? e : {}))
              .toList() ??
          const [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      healthBenefits: (json['healthBenefits'] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      healthRisks: (json['healthRisks'] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      recommendedFor: (json['recommendedFor'] as List<dynamic>?)
          ?.map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(),
      notRecommendedFor: (json['notRecommendedFor'] as List<dynamic>?)
          ?.map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(),
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }

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

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      ingredient: json['ingredient'] as String? ?? 'Unknown Ingredient',
      category: json['category'] as String? ?? 'Unknown',
      healthScore: (json['healthScore'] as num?)?.toInt() ?? 50,
      indicator: json['indicator'] as String? ?? 'YELLOW',
      avoid: json['avoid'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
      details: json['details'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$IngredientDetailToJson(this);
}
