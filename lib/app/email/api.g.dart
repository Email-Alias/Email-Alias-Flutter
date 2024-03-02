// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AddEmailRequest _$AddEmailRequestFromJson(Map<String, dynamic> json) =>
    _AddEmailRequest(
      active: json['active'] as bool,
      sogoVisible: json['sogo_visible'] as bool,
      address: json['address'] as String,
      goto: json['goto'] as String,
      privateComment: json['private_comment'] as String,
    );

Map<String, dynamic> _$AddEmailRequestToJson(_AddEmailRequest instance) =>
    <String, dynamic>{
      'active': instance.active,
      'sogo_visible': instance.sogoVisible,
      'address': instance.address,
      'goto': instance.goto,
      'private_comment': instance.privateComment,
    };
