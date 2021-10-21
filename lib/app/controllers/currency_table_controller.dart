import 'package:flutter/cupertino.dart';
import 'package:spark_lib/data/cache.dart';
import 'package:decimal/decimal.dart';
import 'package:more/collection.dart';

import 'package:spark_lib/data/dynamic_table.dart';

import '../db_connections/mariadb_connector.dart';

// Current status: No errors thrown at runtime, but
// data isn't getting loaded into Flutter table.

enum dbModes { local, mariaDB, sqlite }

const int remoteIdCol = 0;
const int remoteNameCol = 1;
const int remoteValueCol = 2;
const int remoteDbOpCol = 3;
const int localNameCol = 0;
const int localValueCol = 1;

class CurrencyTableController {
  DynamicTable dataTable = DynamicTable();
  dbModes dbMode;
  late _DataAdapter _adapter;

  CurrencyTableController({this.dbMode = dbModes.mariaDB}) {
    _adapter = _DataAdapter(dbMode);
  }

  Future initialize() async {
    dataTable = await _adapter.fetchData();
  }

  void setRows(List<DtRow> newRows) {
    dataTable.setRows(newRows);
  }

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
    var row = dataTable.rows[index];
    row[localNameCol] = name;
    row[localValueCol] = currencyValue;
    _adapter.markUpdate(row);
  }

  Future addRow({DtRow? newRow}) async {
    _adapter.markAdd(dataTable.addRow(newRow));
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
    _adapter.markDelete(dataTable.rows[rowID]);
    dataTable.rows.removeAt(rowID);
  }

  void moveRow(int rowID, int targetID) {
    throw UnimplementedError();
  }

  void duplicateRow(int rowID) {
    throw UnimplementedError();
  }

  void addColumn(DtColumn newColumn) {
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
        submitChanges = () async {};
        break;
      default:
        submitChanges = () async {};
    }
  }

  List<DtColumn> remoteColumnSpec = <DtColumn>[
    // From the database
    DtColumn<int>("ID", 0),
    DtColumn<String>("Currency", "null"),
    DtColumn<Decimal>("Value", Decimal.zero),
    // Internal tracking data
    DtColumn<_DbOp>("Database Operation", _DbOp.UNCHANGED),
  ];

  List<DtColumn> localColumnSpec = <DtColumn>[
    DtColumn<String>("Currency", "null"),
    DtColumn<Decimal>("Value", Decimal.zero),
  ];

  // remote, local -> use BiMap.inverse to switch the order.
  BiMap<DtRow, DtRow> rowMap = BiMap<DtRow, DtRow>();

  late DynamicTable remoteTable;

  late DynamicTable localTable;

  late Future Function() submitChanges;

  Future _submitChangesMariaDB() async {
    List<Future> ops = <Future>[];
    List removeRows = [];
    // Submit operation to DB server.
    // On complete, update remoteTable row to match changes.
    // Finally, clear the editing status of the row.
    for (var remoteRow in remoteTable.rows) {
      var localRow = rowMap[remoteRow]!;
      switch (remoteRow[remoteDbOpCol]) {
        case _DbOp.UNCHANGED:
          continue;
        case _DbOp.DELETE:
          removeRows.add(remoteRow);
          break;
        case _DbOp.UPDATE:
          ops.add(mariaDBConnector
              .updateRow(remoteRow[remoteIdCol], localRow[localNameCol],
                  localRow[localValueCol])
              .then((value) {
            remoteRow[remoteNameCol] = localRow[localNameCol];
            remoteRow[remoteValueCol] = localRow[localValueCol];
            remoteRow[remoteDbOpCol] = _DbOp.UNCHANGED;
          }));
          break;
        case _DbOp.ADD_UPDATE:
        case _DbOp.ADD:
          ops.add(mariaDBConnector
              .insertRow(remoteRow[remoteNameCol], remoteRow[remoteValueCol])
              .then((value) {
            remoteRow[remoteIdCol] = value;
            remoteRow[remoteDbOpCol] = _DbOp.UNCHANGED;
          }));
          break;
      }
      remoteRow[remoteDbOpCol] = _DbOp.UNCHANGED;
    }

    for (var item in removeRows) {
      ops.add(mariaDBConnector
          .deleteRow(item[remoteIdCol])
          .then((value) => remoteTable.removeRow(item)));
    }

    await Future.wait(ops).whenComplete(() {
      localTable = extractLocalTable();
    });
    dirty = false;
  }

  void discardChanges() {
    List removeRows = [];
    for (var row in remoteTable.rows) {
      switch (row[remoteDbOpCol]) {
        case _DbOp.UNCHANGED:
          continue;
        case _DbOp.DELETE:
        case _DbOp.UPDATE:
          row[remoteDbOpCol] = _DbOp.UNCHANGED;
          break;
        case _DbOp.ADD_UPDATE:
        case _DbOp.ADD:
          removeRows.add(row);
          // remoteTable.removeRow(row);
          break;
      }
      row[remoteDbOpCol] = _DbOp.UNCHANGED;
    }
    for (var item in removeRows) remoteTable.removeRow(item);
    localTable = extractLocalTable();
    dirty = false;
  }

  void markAdd(DtRow newRow) {
    DtRow addRow = DtRow([
      nullFixed(int),
      newRow[localNameCol],
      newRow[localValueCol],
      _DbOp.ADD
    ]);
    rowMap[remoteTable.addRow(addRow)] = newRow;
    dirty = true;
  }

  void markUpdate(DtRow localRow) {
    var localMap = rowMap.inverse;
    var remoteRow = localMap[localRow]!;
    if (remoteRow[remoteDbOpCol] == _DbOp.ADD)
      remoteRow[remoteDbOpCol] = _DbOp.ADD_UPDATE;
    else
      remoteRow[remoteDbOpCol] = _DbOp.UPDATE;
    dirty = true;
  }

  void markDelete(DtRow localRow) {
    var localMap = rowMap.inverse;
    var remoteRow = localMap[localRow]!;
    if (remoteRow[remoteDbOpCol] == _DbOp.ADD ||
        remoteRow[remoteDbOpCol] == _DbOp.ADD_UPDATE) {
      remoteTable.removeRow(remoteRow);
    } else {
      remoteRow[remoteDbOpCol] = _DbOp.DELETE;
    }
    dirty = true;
  }

  Future<DynamicTable> fetchData() async {
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

    localTable = extractLocalTable();

    return localTable;
  }

  DynamicTable extractLocalTable() {
    rowMap.clear();
    var table = DynamicTable(localColumnSpec);

    for (var row in remoteTable.rows) {
      rowMap[row] = table.addRow(DtRow([
        fix(row[remoteNameCol], String),
        fix(row[remoteValueCol], Decimal),
      ]));
    }

    return table;
  }

  Future<DynamicTable> _fetchCachedData() async {
    return defaultData();
  }

  Future<DynamicTable> _fetchMariaDBData() async {
    if (mariaDBConnector.connection == null) return defaultData();
    var data = await mariaDBConnector.getCurrencyList();
    if (data.fields.length != 3) {
      throw ErrorDescription(
          "Error: Database fields do not match expeted columns");
    }
    DynamicTable newTable = DynamicTable(remoteColumnSpec);
    for (var row in data) {
      newTable.addRow(
        DtRow(
          [
            row[0] as int, // Either submit as casted or Fixed
            row[1] as String,
            Decimal.parse(row[2].toString()),
            _DbOp.UNCHANGED,
          ],
        ),
      );
    }
    return newTable;
  }

  Future<DynamicTable> _fetchSqliteData() async {
    return defaultData();
  }

  DynamicTable defaultData() {
    int i = 0;
    var newTable = DynamicTable(remoteColumnSpec);
    newTable.setRows([
      DtRow([
        i++,
        "INR",
        Decimal.parse('1'),
        _DbOp.UNCHANGED,
      ]),
      DtRow([
        i++,
        "USD",
        Decimal.parse('75'),
        _DbOp.UNCHANGED,
      ]),
      DtRow([
        i++,
        "EUR",
        Decimal.parse('85'),
        _DbOp.UNCHANGED,
      ]),
      DtRow([
        i++,
        "SAR",
        Decimal.parse('20'),
        _DbOp.UNCHANGED,
      ]),
      DtRow([
        i++,
        "POUND",
        Decimal.parse('5'),
        _DbOp.UNCHANGED,
      ]),
      DtRow([
        i++,
        "DEM",
        Decimal.parse('43'),
        _DbOp.UNCHANGED,
      ]),
    ]);
    return newTable;
  }
}

enum _DbOp { UPDATE, DELETE, ADD, UNCHANGED, ADD_UPDATE }
