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
      goto: const StringToSetConverter().fromJson(json['goto'] as String),
      privateComment: json['private_comment'] as String,
    );

Map<String, dynamic> _$AddEmailRequestToJson(_AddEmailRequest instance) =>
    <String, dynamic>{
      'active': instance.active,
      'sogo_visible': instance.sogoVisible,
      'address': instance.address,
      'goto': const StringToSetConverter().toJson(instance.goto),
      'private_comment': instance.privateComment,
    };

_AddEmailResponse _$AddEmailResponseFromJson(Map<String, dynamic> json) =>
    _AddEmailResponse(
      msg: (json['msg'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AddEmailResponseToJson(_AddEmailResponse instance) =>
    <String, dynamic>{
      'msg': instance.msg,
    };

_UpdateEmailRequest _$UpdateEmailRequestFromJson(Map<String, dynamic> json) =>
    _UpdateEmailRequest(
      items: (json['items'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      attr:
          _UpdateEmailAttributes.fromJson(json['attr'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateEmailRequestToJson(_UpdateEmailRequest instance) =>
    <String, dynamic>{
      'items': instance.items,
      'attr': instance.attr,
    };

_UpdateEmailAttributes _$UpdateEmailAttributesFromJson(
        Map<String, dynamic> json) =>
    _UpdateEmailAttributes(
      goto: _$JsonConverterFromJson<String, Set<String>>(
          json['goto'], const StringToSetConverter().fromJson),
      active: _$JsonConverterFromJson<int, bool>(
          json['active'], const IntToBoolConverter().fromJson),
    );

Map<String, dynamic> _$UpdateEmailAttributesToJson(
    _UpdateEmailAttributes instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'goto',
      _$JsonConverterToJson<String, Set<String>>(
          instance.goto, const StringToSetConverter().toJson));
  writeNotNull(
      'active',
      _$JsonConverterToJson<int, bool>(
          instance.active, const IntToBoolConverter().toJson));
  return val;
}

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
