import 'dart:convert';
import 'dart:io';

import 'package:email_alias/app/config/config_controller.dart';
import 'package:email_alias/app/email/email.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'api.g.dart';

(Uri, Map<String, String>) _uriAndHeaders(final String path) {
  final config = ConfigController().config!;
  return (
    Uri.https(config.apiDomain, '/api/v1/$path'),
    {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
      'X-API-Key': config.apiKey,
    }
  );
}

Future<List<Email>> getEmails() async {
  final (uri, headers) = _uriAndHeaders('get/alias/all');
  
  final resp = await http.get(uri, headers: headers);
  return (
    jsonDecode(resp.body) as List)
      .map((final e) => Email.fromJson(e as Map<String, dynamic>),
  ).toList();
}

Future<void> addEmail({required final String address, required final String goto, required final String privateComment}) async {
  final (uri, headers) = _uriAndHeaders('add/alias');
  final request = _AddEmailRequest(
    active: true,
    sogoVisible: false,
    address: address,
    goto: goto,
    privateComment: privateComment,
  );
  final body = jsonEncode(request);
  await http.post(uri, headers: headers, body: body);
}

Future<void> deleteEmail({required final int id}) async {
  final (uri, headers) = _uriAndHeaders('delete/alias');
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
  final String goto;
  final String privateComment;

  Map<String, dynamic> toJson() => _$AddEmailRequestToJson(this);
}
