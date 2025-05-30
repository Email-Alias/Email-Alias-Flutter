import 'package:email_alias/app/database/email.dart';
import 'package:hive_ce/hive.dart';

@GenerateAdapters([AdapterSpec<Email>()])
part 'hive_adapters.g.dart';