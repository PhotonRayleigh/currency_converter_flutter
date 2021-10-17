import 'package:currency_converter_flutter/app/db_adapters/db_adapter.dart';
import 'package:flutter/cupertino.dart';
import '../db_connections/mariadb_connector.dart';

class SqlAdapter extends DbAdapter {
  Future fetchData() async {
    var results = await mariaDBConnector.getCurrencyList();
  }
}

class TypedTable {}

typedef TypedTableData = List<TypedRow>;

typedef TypeList = List<Type>;

typedef TypedRowCells = List<Object>;

class TypedRow {
  late TypeList _types;
  late TypedRowCells _cells;
  TypedRow({TypedRowCells? cells, TypeList? types}) {
    if (types != null && cells != null) {
      // if both supplied, check and set
      if (types.length == 0)
        throw ErrorDescription("Error: types cannot be empty.");
      if (cells.length != types.length)
        throw ErrorDescription(
            "Error: Length of row cells and type list do not match");
      _types = types;
      for (int i = 0; i < _types.length; i++) {
        if (cells[i].runtimeType != _types[i])
          ErrorDescription(
              "Error: cell $i in TypedRow is type ${cells[i].runtimeType} and does not match supplied type ${_types[i]}");
      }
      _cells = cells;
      return;
    }
    // If types but no cells, make empty cells
    if (cells == null && types != null) {
      if (types.length == 0)
        throw ErrorDescription("Error: types cannot be empty.");
      _types = types;
      _cells = <Object>[];
      return;
    }
    // If cells but no types, infer types
    if (cells != null && types == null) {
      if (cells.length == 0)
        ErrorDescription("Error: cells as a solo argument cannot be empty.");
      _types = <Type>[];
      _cells = cells;
      for (int i = 0; i < cells.length; i++) {
        _types.add(cells[i].runtimeType);
      }
      return;
    }
    // else if both are null, throw error
    throw ErrorDescription("Error: both cells and types cannot be null");
  }

  Object operator [](int index) {
    _rangeCheck(index);
    return _cells[index];
  }

  operator []=(int index, Object newData) {
    _rangeCheck(index);
    if (_types[index] != newData.runtimeType) throw TypeError();
    _cells[index] = newData;
  }

  T? get<T>(int index) {
    _rangeCheck(index);
    if (T == _types[index]) {
      return _cells[index] as T;
    } else
      return null;
  }

  void set<T>(int index, T newData) {
    _rangeCheck(index);
    if (T == _types[index]) {
      _cells[index] = newData as Object;
    } else {
      throw TypeError();
    }
  }

  void _rangeCheck(int index) {
    if (index < 0 || index >= _cells.length)
      throw RangeError.index(index, this);
    return;
  }

  void printTypes() {
    print("TypedRow contains the following types:");
    for (var type in _types) {
      print(type.toString());
    }
  }

  void addCell() {
    throw UnimplementedError();
  }

  void removeCell() {
    throw UnimplementedError();
  }

  static TypedRow from(TypedRow row) {
    throw UnimplementedError();
  }
}
