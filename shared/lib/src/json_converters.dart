import 'package:json_annotation/json_annotation.dart';

final class StringToSetConverter implements JsonConverter<Set<String>, String> {
  const StringToSetConverter();

  @override
  Set<String> fromJson(final String json) => json.split(',').map((final e) => e.trim()).toSet();

  @override
  String toJson(final Set<String> object) => object.where((final e) => e.isNotEmpty).join(',');
}

final class IntToBoolConverter implements JsonConverter<bool, int> {
  const IntToBoolConverter();

  @override
  bool fromJson(final int json) => json == 1;

  @override
  int toJson(final bool object) => object ? 1 : 0;
}