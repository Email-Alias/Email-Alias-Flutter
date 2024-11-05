import 'package:email_alias/app/database/email.dart';
import 'package:floor/floor.dart';

@dao
abstract class EmailDao {
  @Query('SELECT * FROM Email')
  Future<List<Email>> getAll();

  @Query('SELECT * FROM Email')
  Stream<List<Email>> getAllStream();

  @insert
  Future<void> insertEmail(final Email email);

  @insert
  Future<void> insertEmails(final List<Email> emails);

  @update
  Future<void> updateEmail(final Email email);

  @delete
  Future<void> deleteEmail(final Email email);
  
  @Query('DELETE FROM Email')
  Future<void> deleteAll();
}
