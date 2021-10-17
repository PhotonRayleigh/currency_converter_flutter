import 'package:flutter/cupertino.dart';
import 'package:spark_lib/data/cache.dart';
import 'package:decimal/decimal.dart';

import 'package:spark_lib/data/dynamic_table.dart' as dt;

import '../db_connections/mariadb_connector.dart';

// Current status: No errors thrown at runtime, but
// data isn't getting loaded into Flutter table.

enum dbModes { local, mariaDB, sqlite }

class CurrencyTableController {
  dt.DynamicTable dataTable = dt.DynamicTable();
  dbModes dbMode;
  late _DataAdapter _adapter;

  CurrencyTableController({this.dbMode = dbModes.mariaDB}) {
    _adapter = _DataAdapter(dbMode);
  }

  Future initialize() async {
    dataTable = await _adapter.fetchData();
  }

  void setRows(List<dt.Row> newRows) {
    dataTable.setRows(newRows);
  }

  Future addRow({dt.Row? newRow}) async {
    if (newRow != null) {
      dataTable.addRow(row: newRow);
      mariaDBConnector.insertRow(newRow[1] as String, newRow[2] as Decimal);
    } else {
      dt.Row genRow = dataTable.addRow();
      int newID = await mariaDBConnector.insertRow(
          genRow[1] as String, genRow[2] as Decimal);
      genRow[0] = newID;
    }
  }

  void deleteRow(int rowID) {
    int dbID = dataTable.rows[rowID][0] as int;
    dataTable.removeRowAt(rowID);
    // if (columns[0].name == "ID" && columns[0].type == int) {
    //   int i = 0;
    //   for (var row in rows) {
    //     row[0] = i;
    //     i++;
    //   }
    // }
    mariaDBConnector.deleteRow(dbID);
  }

  void moveRow(int rowID, int targetID) {
    throw UnimplementedError();
  }

  void duplicateRow(int rowID) {
    throw UnimplementedError();
  }

  void addColumn(dt.Column newColumn) {
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
  dbModes mode;
  _DataAdapter(this.mode);
  List<dt.Column> columnSpec = <dt.Column>[
    dt.Column<int>("ID", 0),
    dt.Column<String>("Currency", "null"),
    dt.Column<Decimal>("Value", Decimal.zero),
  ];

  Future<dt.DynamicTable> fetchData() async {
    switch (mode) {
      case dbModes.local:
        return await _fetchCachedData();
      // break;
      case dbModes.mariaDB:
        return await _fetchMariaDBData();
      // break;
      case dbModes.sqlite:
        return await _fetchSqliteData();
      // break;
    }
  }

  Future<dt.DynamicTable> _fetchCachedData() async {
    return defaultData();
  }

  Future<dt.DynamicTable> _fetchMariaDBData() async {
    if (mariaDBConnector.connection == null) return defaultData();
    var data = await mariaDBConnector.getCurrencyList();
    if (data.fields.length != 3) {
      throw ErrorDescription(
          "Error: Database fields do not match expeted columns");
    }
    dt.DynamicTable newTable = dt.DynamicTable(columns: columnSpec);
    for (var row in data) {
      newTable.addRow(
        row: dt.Row(
          cells: dt.TypedList(
            list: [
              dt.Cell<int>(row[0]),
              dt.Cell<String>(row[1]),
              dt.Cell<Decimal>(Decimal.parse(row[2].toString())),
            ],
          ),
        ),
      );
    }
    return newTable;
  }

  Future<dt.DynamicTable> _fetchSqliteData() async {
    return defaultData();
  }

  dt.DynamicTable defaultData() {
    int i = 0;
    var newTable = dt.DynamicTable(columns: columnSpec);
    newTable.setRows([
      dt.Row(
          cells: dt.TypedList(list: [
        dt.Cell<int>(i++),
        dt.Cell<String>("INR"),
        dt.Cell<Decimal>(Decimal.parse('1')),
      ])),
      dt.Row(
          cells: dt.TypedList(list: [
        dt.Cell<int>(i++),
        dt.Cell<String>("USD"),
        dt.Cell<Decimal>(Decimal.parse('75')),
      ])),
      dt.Row(
          cells: dt.TypedList(list: [
        dt.Cell<int>(i++),
        dt.Cell<String>("EUR"),
        dt.Cell<Decimal>(Decimal.parse('85')),
      ])),
      dt.Row(
          cells: dt.TypedList(list: [
        dt.Cell<int>(i++),
        dt.Cell<String>("SAR"),
        dt.Cell<Decimal>(Decimal.parse('20')),
      ])),
      dt.Row(
          cells: dt.TypedList(list: [
        dt.Cell<int>(i++),
        dt.Cell<String>("POUND"),
        dt.Cell<Decimal>(Decimal.parse('5')),
      ])),
      dt.Row(
          cells: dt.TypedList(list: [
        dt.Cell<int>(i++),
        dt.Cell<String>("DEM"),
        dt.Cell<Decimal>(Decimal.parse('43')),
      ])),
    ]);
    return newTable;
  }
}
