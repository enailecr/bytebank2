import 'package:bytebank2/dao/contact_dao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> getDatabase() async {
  print(getDatabasesPath());
  final String path = join(await getDatabasesPath(), 'bytebank2.db');
  return openDatabase(
    path,
    onCreate: (db, version) {
      db.execute(ContactDao.tableSql);
    },
    version: 1,
    // onUpgrade: onDatabaseDowngradeDelete,
  );
}
