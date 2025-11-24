import 'dart:convert';
import 'dart:io';

import 'package:email_alias/app/config/config_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/shared.dart';

part 'api.g.dart';

final testDomain = 'test.mail.opdehipt.com';
final testEmail = 'test@example.com';

Future<(Uri, Map<String, String>)> _uriAndHeaders(final String path) async {
  final config = ConfigController().value!;
  final apiKey = await ConfigController.instance.apiKey;
  return (
    Uri.https(config.apiDomain, '/api/v1/$path'),
    {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
      'X-API-Key': apiKey!,
    }
  );
}

Future<List<Email>> getEmails() async {
  final (uri, headers) = await _uriAndHeaders('get/alias/all');
  
  final resp = await http.get(uri, headers: headers);
  return (
    jsonDecode(resp.body) as List)
      .map((final e) => Email.fromJson(e as Map<String, dynamic>),
  ).toList();
}

Future<int> addEmail({required final String address, required final String privateComment, required final Set<String> goto}) async {
  final (uri, headers) = await _uriAndHeaders('add/alias');
  final request = _AddEmailRequest(
    active: true,
    sogoVisible: false,
    address: address,
    goto: goto,
    privateComment: privateComment,
  );
  final body = jsonEncode(request);
  final resp = await http.post(uri, headers: headers, body: body);
  return int.parse(_AddEmailResponse.fromJson((jsonDecode(resp.body) as List)[0]).msg[2]);
}

Future<void> updateEmail({required final int id, final Set<String>? goto, final bool? active}) async {
  final (uri, headers) = await _uriAndHeaders('edit/alias');
  final request = _UpdateEmailRequest.fromId(id: id, goto: goto, active: active);
  final body = jsonEncode(request);
  await http.post(uri, headers: headers, body: body);
}

Future<void> deleteEmail({required final int id}) async {
  final (uri, headers) = await _uriAndHeaders('delete/alias');
  final body = jsonEncode([id]);
  await http.post(uri, headers: headers, body: body);
}

@immutable
@JsonSerializable(fieldRename: FieldRename.snake)
final class _AddEmailRequest {
  const _AddEmailRequest({required this.active, required this.sogoVisible, required this.address, required this.goto, required this.privateComment});

  final bool active;
  final bool sogoVisible;
  final String address;
  @StringToSetConverter()
  final Set<String> goto;
  final String privateComment;

  Map<String, dynamic> toJson() => _$AddEmailRequestToJson(this);
}

@immutable
@JsonSerializable()
final class _AddEmailResponse {
  const _AddEmailResponse({required this.msg});

  factory _AddEmailResponse.fromJson(final Map<String, dynamic> json) => _$AddEmailResponseFromJson(json);

  final List<String> msg;
}

@immutable
@JsonSerializable()
final class _UpdateEmailRequest {
  const _UpdateEmailRequest({required this.items, required this.attr});

  _UpdateEmailRequest.fromId({required final int id, required final Set<String>? goto, required final bool? active})
      : this(items: [id], attr: _UpdateEmailAttributes(goto: goto, active: active));

  final List<int> items;
  final _UpdateEmailAttributes attr;

  Map<String, dynamic> toJson() => _$UpdateEmailRequestToJson(this);
}

@immutable
@JsonSerializable()
final class _UpdateEmailAttributes {
  const _UpdateEmailAttributes({required this.goto, required this.active});

  factory _UpdateEmailAttributes.fromJson(final Map<String, dynamic> json) => _$UpdateEmailAttributesFromJson(json);

  @StringToSetConverter()
  @JsonKey(includeIfNull: false)
  final Set<String>? goto;
  @IntToBoolConverter()
  @JsonKey(includeIfNull: false)
  final bool? active;

  Map<String, dynamic> toJson() => _$UpdateEmailAttributesToJson(this);
}
