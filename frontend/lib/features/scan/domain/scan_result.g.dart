// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScanResult _$ScanResultFromJson(Map<String, dynamic> json) => ScanResult(
  productName: json['productName'] as String,
  overallHealthScore: (json['overallHealthScore'] as num).toInt(),
  overallIndicator: json['overallIndicator'] as String,
  summary: json['summary'] as String,
  goodIngredients: (json['goodIngredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  neutralIngredients: (json['neutralIngredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  badIngredients: (json['badIngredients'] as List<dynamic>)
      .map((e) => IngredientDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  healthBenefits: (json['healthBenefits'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  healthRisks: (json['healthRisks'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendedFor: (json['recommendedFor'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  notRecommendedFor: (json['notRecommendedFor'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  disclaimer: json['disclaimer'] as String,
);

Map<String, dynamic> _$ScanResultToJson(ScanResult instance) =>
    <String, dynamic>{
      'productName': instance.productName,
      'overallHealthScore': instance.overallHealthScore,
      'overallIndicator': instance.overallIndicator,
      'summary': instance.summary,
      'goodIngredients': instance.goodIngredients,
      'neutralIngredients': instance.neutralIngredients,
      'badIngredients': instance.badIngredients,
      'warnings': instance.warnings,
      'healthBenefits': instance.healthBenefits,
      'healthRisks': instance.healthRisks,
      'recommendedFor': instance.recommendedFor,
      'notRecommendedFor': instance.notRecommendedFor,
      'disclaimer': instance.disclaimer,
    };

IngredientDetail _$IngredientDetailFromJson(Map<String, dynamic> json) =>
    IngredientDetail(
      ingredient: json['ingredient'] as String,
      category: json['category'] as String,
      healthScore: (json['healthScore'] as num).toInt(),
      indicator: json['indicator'] as String,
      avoid: json['avoid'] as bool,
      reason: json['reason'] as String,
      details: json['details'] as String,
    );

Map<String, dynamic> _$IngredientDetailToJson(IngredientDetail instance) =>
    <String, dynamic>{
      'ingredient': instance.ingredient,
      'category': instance.category,
      'healthScore': instance.healthScore,
      'indicator': instance.indicator,
      'avoid': instance.avoid,
      'reason': instance.reason,
      'details': instance.details,
    };
