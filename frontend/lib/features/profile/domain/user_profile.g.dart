// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: json['id'] as String,
  username: json['username'] as String?,
  phoneNumber: json['phoneNumber'] as String,
  age: (json['age'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toDouble(),
  weight: (json['weight'] as num?)?.toDouble(),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'phoneNumber': instance.phoneNumber,
      'age': instance.age,
      'height': instance.height,
      'weight': instance.weight,
    };
