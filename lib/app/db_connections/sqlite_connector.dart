import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:decimal/decimal.dart';
import 'dart:async';

final _SqliteConnector sqliteConnector = _SqliteConnector();

class _SqliteConnector {
  Database? db;
  static const String currencyTableName = "currency_table";
  late Future initialized;
  Completer initCompleter = Completer();

  _SqliteConnector() {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    initialized = initCompleter.future;
  }

  Future openDB() async {
    // On Windows this path is an app-specific folder in AppData/Roaming
    Directory dir = await getApplicationSupportDirectory();
    print(dir);
    if (db == null)
      db = await openDatabase(p.join(dir.path, 'currencyData.db'));
    initCompleter.complete();
  }

  Future closeDB() async {
    await initialized;
    if (db != null) await db!.close();
  }

  Future<bool> checkDB() async {
    await initialized;
    var db = this.db!;

    var tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';");
    if (tables.length == 0) return false;

    for (var row in tables) {
      if (row["name"] == currencyTableName) return true;
    }

    return false;
  }

  Future<List<Map<String, Object?>>> getCurrencyDataTrimmed() async {
    await initialized;
    var results =
        await db!.query(currencyTableName, columns: ["name", "value"]);
    return results;
  }

  Future<List<Map<String, Object?>>> getCurrencyDataFull() async {
    await initialized;
    var results =
        await db!.query(currencyTableName, columns: ["id", "name", "value"]);
    return results;
  }

  Future<void> createCurrencyTable() async {
    await initialized;
    await db!.execute(
        "CREATE TABLE $currencyTableName (id INTEGER PRIMARY KEY," +
            "name TEXT, value TEXT);");
  }

  Future<void> populateDefaultData() async {
    await initialized;
    var batch = db!.batch();
    batch.delete(currencyTableName);
    for (var row in _defaultData) {
      batch.insert(currencyTableName, row);
    }
    await batch.commit();
  }
}

// Table schema is int, string, Decimal. Int is handled automatically.
List<Map<String, Object?>> _defaultData = [
  {"name": "INR", "value": '1'},
  {"name": "USD", "value": '75'},
  {"name": "EUR", "value": '85'},
  {"name": "SAR", "value": '20'},
  {"name": "POUND", "value": '5'},
  {"name": "DEM", "value": '43'},
];
