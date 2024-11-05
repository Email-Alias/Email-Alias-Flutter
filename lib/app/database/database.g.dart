// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  EmailDao? _emailDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Email` (`id` INTEGER NOT NULL, `address` TEXT NOT NULL, `privateComment` TEXT, `goto` TEXT NOT NULL, `active` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  EmailDao get emailDao {
    return _emailDaoInstance ??= _$EmailDao(database, changeListener);
  }
}

class _$EmailDao extends EmailDao {
  _$EmailDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _emailInsertionAdapter = InsertionAdapter(
            database,
            'Email',
            (Email item) => <String, Object?>{
                  'id': item.id,
                  'address': item.address,
                  'privateComment': item.privateComment,
                  'goto': __StringToSetConverter.encode(item.goto),
                  'active': item.active ? 1 : 0
                },
            changeListener),
        _emailUpdateAdapter = UpdateAdapter(
            database,
            'Email',
            ['id'],
            (Email item) => <String, Object?>{
                  'id': item.id,
                  'address': item.address,
                  'privateComment': item.privateComment,
                  'goto': __StringToSetConverter.encode(item.goto),
                  'active': item.active ? 1 : 0
                },
            changeListener),
        _emailDeletionAdapter = DeletionAdapter(
            database,
            'Email',
            ['id'],
            (Email item) => <String, Object?>{
                  'id': item.id,
                  'address': item.address,
                  'privateComment': item.privateComment,
                  'goto': __StringToSetConverter.encode(item.goto),
                  'active': item.active ? 1 : 0
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Email> _emailInsertionAdapter;

  final UpdateAdapter<Email> _emailUpdateAdapter;

  final DeletionAdapter<Email> _emailDeletionAdapter;

  @override
  Future<List<Email>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM Email',
        mapper: (Map<String, Object?> row) => Email(
            id: row['id'] as int,
            address: row['address'] as String,
            privateComment: row['privateComment'] as String?,
            goto: __StringToSetConverter.decode(row['goto'] as String),
            active: (row['active'] as int) != 0));
  }

  @override
  Stream<List<Email>> getAllStream() {
    return _queryAdapter.queryListStream('SELECT * FROM Email',
        mapper: (Map<String, Object?> row) => Email(
            id: row['id'] as int,
            address: row['address'] as String,
            privateComment: row['privateComment'] as String?,
            goto: __StringToSetConverter.decode(row['goto'] as String),
            active: (row['active'] as int) != 0),
        queryableName: 'Email',
        isView: false);
  }

  @override
  Future<void> deleteAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Email');
  }

  @override
  Future<void> insertEmail(Email email) async {
    await _emailInsertionAdapter.insert(email, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertEmails(List<Email> emails) async {
    await _emailInsertionAdapter.insertList(emails, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateEmail(Email email) async {
    await _emailUpdateAdapter.update(email, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteEmail(Email email) async {
    await _emailDeletionAdapter.delete(email);
  }
}

// ignore_for_file: unused_element
final __StringToSetConverter = _StringToSetConverter();
