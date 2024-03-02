import 'package:hive_flutter/adapters.dart';

part 'config.g.dart';

@HiveType(typeId: 1)
final class Config extends HiveObject {
  Config({required this.email, required this.apiDomain, required this.apiKey});

  @HiveField(0)
  final String email;
  @HiveField(1)
  final String apiDomain;
  @HiveField(2)
  final String apiKey;

  String get emailDomain => email.split('@').last;
}
