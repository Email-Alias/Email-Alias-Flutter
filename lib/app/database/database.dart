import 'dart:async';

import 'package:email_alias/app/database/email.dart';
import 'package:email_alias/app/database/email_dao.dart';
import 'package:email_alias/app/json_converters.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

class _StringToSetConverter extends TypeConverter<Set<String>, String> {
  @override
  Set<String> decode(final String databaseValue) => const StringToSetConverter().fromJson(databaseValue);

  @override
  String encode(final Set<String> value) => const StringToSetConverter().toJson(value);
}

late final AppDatabase emailDatabase;

@TypeConverters([_StringToSetConverter])
@Database(version: 1, entities: [Email])
abstract class AppDatabase extends FloorDatabase {
  EmailDao get emailDao;
}
