// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Email _$EmailFromJson(Map<String, dynamic> json) => Email(
      id: (json['id'] as num).toInt(),
      address: json['address'] as String,
      privateComment: json['private_comment'] as String?,
      goto: const StringToSetConverter().fromJson(json['goto'] as String),
      active:
          const IntToBoolConverter().fromJson((json['active'] as num).toInt()),
    );

Map<String, dynamic> _$EmailToJson(Email instance) => <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'private_comment': instance.privateComment,
      'goto': const StringToSetConverter().toJson(instance.goto),
      'active': const IntToBoolConverter().toJson(instance.active),
    };
