import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'email.g.dart';

@immutable
@HiveType(typeId: 2)
@JsonSerializable(fieldRename: FieldRename.snake)
final class Email {
  const Email({required this.id, required this.address, required this.privateComment, required this.goto});

  factory Email.fromJson(final Map<String, dynamic> json) => _$EmailFromJson(json);

  @HiveField(0)
  final int id;
  @HiveField(1)
  final String address;
  @HiveField(2)
  final String? privateComment;
  @HiveField(3)
  final String goto;

  String description({required final AppLocalizations localizations}) => privateComment ?? localizations.noDescription;
}
