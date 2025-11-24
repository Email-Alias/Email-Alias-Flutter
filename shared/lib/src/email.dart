import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared/src/json_converters.dart';

part 'email.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class Email extends HiveObject {
  Email({required this.id, required this.address, required this.privateComment, required this.goto, required this.active});

  factory Email.fromJson(final Map<String, dynamic> json) => _$EmailFromJson(json);

  static Box<Email> get hiveBox => Hive.box<Email>('emails');

  static Future<void> openBox() => Hive.openBox<Email>('emails');

  final int id;
  final String address;
  final String? privateComment;
  @StringToSetConverter()
  Set<String> goto;
  @JsonKey(fromJson: _intToBool)
  bool active;

  Map<String, dynamic> toJson() => _$EmailToJson(this);
}

bool _intToBool(int json) => json == 1;