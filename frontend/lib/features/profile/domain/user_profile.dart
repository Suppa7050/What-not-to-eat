import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String? id;
  final String? username;
  final String? email;
  final int? age;
  final double? height;
  final double? weight;
  final bool hasDiabetes;
  final String? additionalNotes;

  UserProfile({
    this.id,
    this.username,
    this.email,
    this.age,
    this.height,
    this.weight,
    this.hasDiabetes = false,
    this.additionalNotes,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
