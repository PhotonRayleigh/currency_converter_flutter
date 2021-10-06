import 'package:spark_lib/data/cache.dart';

class CurrencyTableController {
  List<ColumnDefinition> columns = <ColumnDefinition>[];
  List<DataTableRow> rows = <DataTableRow>[];

  CurrencyTableController(this.columns);

  void importMap(Map<Object, Object> source) {
    List<DataTableRow> tempRows = <DataTableRow>[];
    List<List<Object>> rowData = <List<Object>>[];
    int i = 0;
    source.forEach((key, value) {
      rowData.add([i, key, value]);
      i++;
    });

    for (int i = 0; i < rowData.length; i++) {
      tempRows.add(DataTableRow(columns, rowData[i]));
    }
    rows = tempRows;
  }

  void setRows(List<List<Object>> newRows) {
    rows = <DataTableRow>[];
    for (var newRow in newRows) {
      rows.add(DataTableRow(columns, newRow));
    }
  }

  void addRow({List<Object>? newRow}) {
    if (newRow != null)
      rows.add(DataTableRow(columns, newRow));
    else {
      List<Object> tempList = <Object>[];
      for (var col in columns) {
        if (col.name.toUpperCase() == "ID" && col.type == int) {
          tempList.add(col.defaultVal + rows.length);
        } else
          tempList.add(col.defaultVal);
      }
      rows.add(DataTableRow(columns, tempList));
    }
  }

  void deleteRow(int rowID) {
    rows.removeAt(rowID);
    if (columns[0].name == "ID" && columns[0].type == int) {
      int i = 0;
      for (var row in rows) {
        row[0] = i;
        i++;
      }
    }
  }

  void moveRow(int rowID, int targetID) {
    throw UnimplementedError();
  }

  void duplicateRow(int rowID) {
    throw UnimplementedError();
  }

  void addColumn(ColumnDefinition newColumn) {
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

  void loadFromMemroy(Cache cache, int id) {
    if (cache[id] == null || cache[id].runtimeType != CurrencyTableController)
      throw ArgumentError.notNull("cache[$id]");
    CurrencyTableController temp = cache[id]!;
    this.columns = temp.columns;
    this.rows = temp.rows;
  }
}

class ColumnDefinition<T> {
  String name = "";
  Type type = T;
  T defaultVal;

  ColumnDefinition(this.name, this.defaultVal);
}

class DataTableRow {
  List<ColumnDefinition> columns;
  late List<Object> rowData;

  DataTableRow(this.columns, List<Object> data) {
    if (columns.length != data.length)
      throw RangeError(
          "length of 'data' must much length of column definitions.");
    rowData = List.filled(columns.length, Object());

    for (int i = 0; i < columns.length; i++) {
      if (columns[i].type == data[i].runtimeType) {
        rowData[i] = data[i];
      } else {
        throw TypeError();
      }
    }
  }

  operator []=(int index, Object value) {
    if (value.runtimeType == columns[index].type) {
      rowData[index] = value;
    } else
      throw TypeError();
  }

  Object operator [](int index) {
    return rowData[index];
  }
}
