import 'package:currency_converter_flutter/app/db_connections/sqlite_connector.dart';
import 'package:flutter/cupertino.dart';
import 'package:spark_lib/data/cache.dart';
import 'package:decimal/decimal.dart';
import 'package:more/collection.dart';

import '../db_connections/mariadb_connector.dart';

// Current status: No errors thrown at runtime, but
// data isn't getting loaded into Flutter table.

enum dbModes { local, mariaDB, sqlite }

class CurrencyTableController {
  List<MapRow> dataTable = [];
  dbModes dbMode;
  late _DataAdapter _adapter;

  CurrencyTableController({this.dbMode = dbModes.sqlite}) {
    _adapter = _DataAdapter(dbMode);
  }

  Future initialize() async {
    dataTable = await _adapter.fetchData();
  }

  // NOTE: Cannot use this until it can be tracked in _DataAdapter
  // void setRows(List<MapRow> newRows) {
  //   dataTable = List.from(newRows);
  // }

  bool get isDirty {
    return _adapter.dirty;
  }

  Future submitChanges() async {
    await _adapter.submitChanges();
    dataTable = _adapter.localTable;
  }

  void discardChanges() {
    _adapter.discardChanges();
    dataTable = _adapter.localTable;
  }

  void updateRow(int index, String name, Decimal currencyValue) {
    var row = dataTable[index];
    row["name"] = name;
    row["value"] = currencyValue;
    _adapter.markUpdate(row);
  }

  Future addRow({required MapRow newRow}) async {
    dataTable.add(newRow);
    _adapter.markAdd(newRow);
    // if (newRow != null) {
    //   dataTable.addRow(newRow);
    //   mariaDBConnector.insertRow(newRow[1] as String, newRow[2] as Decimal);
    // } else {
    //   DtRow genRow = dataTable.addRow();
    //   int newID = await mariaDBConnector.insertRow(
    //       genRow[1] as String, genRow[2] as Decimal);
    //   genRow[0] = newID;
    // }
  }

  void deleteRow(int rowID) {
    _adapter.markDelete(dataTable[rowID]);
    dataTable.removeAt(rowID);
  }

  void moveRow(int rowID, int targetID) {
    throw UnimplementedError();
  }

  void duplicateRow(int rowID) {
    throw UnimplementedError();
  }

  void addColumn(MapRow newColumn) {
    throw UnimplementedError();
  }

  void duplicateColumn(int colID) {
    throw UnimplementedError();
  }

  void moveColumn(int colID, int targetID) {
    throw UnimplementedError();
  }

  void deleteColumn(int colID, int targetID) {
    throw UnimplementedError();
  }

  void saveToMemory(Cache cache, int id) {
    cache[id] = this;
  }

  // void loadFromMemory(Cache cache, int id) {
  //   if (cache[id] == null || cache[id].runtimeType != CurrencyTableController)
  //     throw ArgumentError.notNull("cache[$id]");
  //   CurrencyTableController temp = cache[id]!;
  //   this.columns = temp.columns;
  //   this.rows = temp.rows;
  // }
}

class _DataAdapter {
  bool dirty = false;

  dbModes mode;
  _DataAdapter(this.mode) {
    switch (mode) {
      case dbModes.local:
        submitChanges = () async {};
        break;
      case dbModes.mariaDB:
        submitChanges = _submitChangesMariaDB;
        break;
      case dbModes.sqlite:
        submitChanges = _submitChangesSqlite;
        break;
      default:
        submitChanges = () async {};
    }
  }

  // remote, local -> use BiMap.inverse to switch the order.
  BiMap<MapRow, MapRow> rowMap = BiMap<MapRow, MapRow>();

  late List<MapRow> remoteTable;
  static const String idCol = "id";
  static const String dbOpCol = "Op";

  late List<MapRow> localTable;
  static const String nameCol = "name";
  static const String valueCol = "value";

  MapRow getRemoteRow(MapRow localRow) {
    return rowMap.inverse[localRow]!;
  }

  MapRow getLocalRow(MapRow remoteRow) {
    return rowMap[remoteRow]!;
  }

  late Future Function() submitChanges;

  Future _submitChangesSqlite() async {
    // Note: local data is store as int, String, Decimal
    // Database data is stored as int, String, String
    // Make sure to correctly convert during transactions.
    List<Future> ops = [];
    var db = sqliteConnector.db!;
    List<MapRow> removeRows = [];
    for (var remoteRow in remoteTable) {
      var localRow = getLocalRow(remoteRow);
      switch (remoteRow[dbOpCol]) {
        case _DbOp.UNCHANGED:
          continue;
        case _DbOp.DELETE:
          removeRows.add(remoteRow);
          break;
        case _DbOp.UPDATE:
          ops.add(db
              .update(
                  "currency_table",
                  {
                    "name": localRow["name"],
                    "value": localRow["value"].toString()
                  },
                  where: "id=?",
                  whereArgs: [remoteRow["id"]])
              .then((result) async {
            var query = await db.query("currency_table",
                where: "id=?", whereArgs: [remoteRow["id"]]);
            var row = query[0];
            bool check = row["name"] == localRow["name"] &&
                row["value"] == localRow["value"];
            if (!check) {
              print(
                  "Error: row ${remoteRow['id']} for currency ${localRow['name']} did not match SQLite verification");
              print("Expected name ${localRow["name"]}, got ${row["name"]}");
              print("Expected value ${localRow["value"]}, got ${row["value"]}");
            }
            remoteRow["name"] = localRow["name"];
            remoteRow["value"] = localRow["value"];
            remoteRow["Op"] = _DbOp.UNCHANGED;
          }));
          break;
        case _DbOp.ADD_UPDATE:
        case _DbOp.ADD:
          ops.add(db.insert("currency_table", {
            "name": localRow["name"],
            "value": localRow["value"].toString()
          }).then((value) {
            remoteRow["id"] = value;
            remoteRow["name"] = localRow["name"];
            remoteRow["value"] = localRow["value"];
            remoteRow["Op"] = _DbOp.UNCHANGED;
          }));
          break;
      }
    }
    for (var row in removeRows) {
      ops.add(db.delete("currency_table",
          where: "id=?", whereArgs: [row["id"]]).then((value) {
        if (value > 1)
          print(
              "Error: removal of currency ${row['name']} removed too many rows");
        else if (value < 1)
          print("Error: removal of currency ${row['name']} failed");
        else
          remoteTable.remove(row);
      }));
    }

    await Future.wait(ops).whenComplete(() => prepareTables());
    dirty = false;
  }

  Future _submitChangesMariaDB() async {
    List<Future> ops = <Future>[];
    List<MapRow> removeRows = [];
    // Submit operation to DB server.
    // On complete, update remoteTable row to match changes.
    // Finally, clear the editing status of the row.
    for (var remoteRow in remoteTable) {
      var localRow = getLocalRow(remoteRow);
      switch (remoteRow[dbOpCol]) {
        case _DbOp.UNCHANGED:
          continue;
        case _DbOp.DELETE:
          removeRows.add(remoteRow);
          break;
        case _DbOp.UPDATE:
          ops.add(mariaDBConnector
              .updateRow(remoteRow[idCol] as int, localRow[nameCol] as String,
                  localRow[valueCol] as Decimal)
              .then((value) {
            remoteRow[nameCol] = localRow[nameCol];
            remoteRow[valueCol] = localRow[valueCol];
            remoteRow[dbOpCol] = _DbOp.UNCHANGED;
          }));
          break;
        case _DbOp.ADD_UPDATE:
        case _DbOp.ADD:
          ops.add(mariaDBConnector
              .insertRow(
                  remoteRow[nameCol] as String, remoteRow[valueCol] as Decimal)
              .then((value) {
            remoteRow[idCol] = value;
            remoteRow[dbOpCol] = _DbOp.UNCHANGED;
          }));
          break;
      }
      remoteRow[dbOpCol] = _DbOp.UNCHANGED;
    }

    for (var item in removeRows) {
      ops.add(mariaDBConnector
          .deleteRow(item[idCol] as int)
          .then((value) => remoteTable.remove(item)));
    }

    await Future.wait(ops).whenComplete(() {
      prepareTables();
    });
    dirty = false;
  }

  void discardChanges() {
    List removeRows = [];
    for (var row in remoteTable) {
      switch (row[dbOpCol]) {
        case _DbOp.UNCHANGED:
          continue;
        case _DbOp.DELETE:
        case _DbOp.UPDATE:
          row[dbOpCol] = _DbOp.UNCHANGED;
          break;
        case _DbOp.ADD_UPDATE:
        case _DbOp.ADD:
          removeRows.add(row);
          // remoteTable.removeRow(row);
          break;
      }
      row[dbOpCol] = _DbOp.UNCHANGED;
    }
    for (var item in removeRows) remoteTable.remove(item);
    prepareTables();
    dirty = false;
  }

  void markAdd(MapRow newLocalRow) {
    // Create new full row from submitted local row
    MapRow newRemoteRow = {
      idCol: null,
      nameCol: newLocalRow[nameCol],
      valueCol: newLocalRow[valueCol],
      dbOpCol: _DbOp.ADD,
    };
    // Add the new full row to the remote table
    remoteTable.add(newRemoteRow);
    // associate the new remote row with the new local row
    rowMap[newRemoteRow] = newLocalRow;
    dirty = true;
  }

  void markUpdate(MapRow localRow) {
    var remoteRow = getRemoteRow(localRow);
    if (remoteRow[dbOpCol] == _DbOp.ADD)
      remoteRow[dbOpCol] = _DbOp.ADD_UPDATE;
    else
      remoteRow[dbOpCol] = _DbOp.UPDATE;
    dirty = true;
  }

  void markDelete(MapRow localRow) {
    var remoteRow = getRemoteRow(localRow);
    if (remoteRow[dbOpCol] == _DbOp.ADD ||
        remoteRow[dbOpCol] == _DbOp.ADD_UPDATE) {
      remoteTable.remove(remoteRow);
    } else {
      remoteRow[dbOpCol] = _DbOp.DELETE;
    }
    dirty = true;
  }

  void prepareTables() {
    rowMap.clear();
    localTable = [];
    for (var row in remoteTable) {
      row[dbOpCol] = _DbOp.UNCHANGED;
      var tempMap = {nameCol: row[nameCol], valueCol: row[valueCol]};
      localTable.add(tempMap);
      rowMap[row] = tempMap;
    }
  }

  Future<List<MapRow>> fetchData() async {
    switch (mode) {
      case dbModes.local:
        remoteTable = await _fetchCachedData();
        break;
      case dbModes.mariaDB:
        remoteTable = await _fetchMariaDBData();
        break;
      case dbModes.sqlite:
        remoteTable = await _fetchSqliteData();
        break;
      default:
        remoteTable = defaultData();
    }

    prepareTables();

    return localTable;
  }

  Future<List<MapRow>> _fetchSqliteData() async {
    // Maps returned from sqlite are read-only.
    // Need to copy into new maps using Map.of()
    var temp = await sqliteConnector.getCurrencyDataFull();
    var editableList = <MapRow>[];
    for (var row in temp) {
      editableList.add({
        "id": row["id"] as int,
        "name": row["name"] as String,
        "value": Decimal.parse(row["value"] as String),
      });
    }
    return editableList;
  }

  Future<List<MapRow>> _fetchCachedData() async {
    return defaultData();
  }

  Future<List<MapRow>> _fetchMariaDBData() async {
    if (mariaDBConnector.connection == null) return defaultData();
    var data = await mariaDBConnector.getCurrencyList();
    if (data.fields.length != 3) {
      throw ErrorDescription(
          "Error: Database fields do not match expeted columns");
    }
    List<MapRow> newTable = <MapRow>[];
    for (var row in data) {
      newTable.add({
        idCol: row[0] as int,
        nameCol: row[1] as String,
        valueCol: Decimal.parse(row[2].toString()),
        dbOpCol: _DbOp.UNCHANGED,
      });
    }
    return newTable;
  }

  List<MapRow> defaultData() {
    int i = 1;
    return <Map<String, Object?>>[
      {"id": i++, "name": "INR", "value": '1'},
      {"id": i++, "name": "USD", "value": '75'},
      {"id": i++, "name": "EUR", "value": '85'},
      {"id": i++, "name": "SAR", "value": '20'},
      {"id": i++, "name": "POUND", "value": '5'},
      {"id": i++, "name": "DEM", "value": '43'},
    ];
  }
}

enum _DbOp { UPDATE, DELETE, ADD, UNCHANGED, ADD_UPDATE }

typedef MapRow = Map<String, Object?>;
