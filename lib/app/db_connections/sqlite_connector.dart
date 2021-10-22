import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

final _SqliteConnector sqliteConnector = _SqliteConnector();

class _SqliteConnector {
  Database? db;

  _SqliteConnector() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future openDB() async {
    // On Windows this path is an app-specific folder in AppData/Roaming
    Directory dir = await getApplicationSupportDirectory();
    print(dir);
    if (db == null)
      db = await openDatabase(p.join(dir.path, 'currencyData.db'));
  }

  Future closeDB() async {
    if (db != null) await db!.close();
  }
}
