import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String id;
  final String? username;
  final String phoneNumber;
  final int? age;
  final double? height;
  final double? weight;

  UserProfile({
    required this.id,
    this.username,
    required this.phoneNumber,
    this.age,
    this.height,
    this.weight,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
