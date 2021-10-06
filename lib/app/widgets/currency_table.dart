import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import 'package:spark_lib/data/cache.dart';

import '../controllers/currency_table_controller.dart';
import '../models/currencies.dart';
import '../screens/db_editor.dart';

class CurrencyTable extends StatefulWidget {
  final Color bgColor;
  late final CurrencyTableController controller;

  CurrencyTable(
      {Key? key,
      this.bgColor = Colors.white,
      CurrencyTableController? controller})
      : super(key: key) {
    if (controller == null) {
      var cols = [
        ColumnDefinition<int>("ID", 0),
        ColumnDefinition<String>("Currency", "null"),
        ColumnDefinition<Decimal>("Value", Decimal.zero),
      ];

      this.controller = CurrencyTableController(cols);
      this.controller.importMap(currencyList);

      // var testRows = [
      //   [0, "USD", Decimal.parse("12")],
      //   [1, "EUR", Decimal.parse("14")],
      //   [2, "RUB", Decimal.parse("6")],
      // ];

      // this.controller.setRows(testRows);
    } else
      this.controller = controller;
  }

  @override
  State<StatefulWidget> createState() {
    return CurrencyTableState();
  }
}

class CurrencyTableState extends State<CurrencyTable> {
  static int cacheID = 0;
  int currentCacheID = 0;
  late CurrencyTableController controller;
  CurrencyDbEditorState? parent;
  bool editing = false;
  int editingIndex = 0;
  DataTableRow? editingRow;

  @override
  void initState() {
    super.initState();
    currentCacheID = cacheID;
    cacheID++;

    controller = widget.controller;
    if (!GlobalCache.cacheMap.containsKey("CurrencyTable")) {
      GlobalCache.cacheMap["CurrencyTable"] = Cache<CurrencyTableController>();
    } else if (GlobalCache.cacheMap["CurrencyTable"]![currentCacheID] != null ||
        GlobalCache.cacheMap["CurrencyTable"]![currentCacheID].runtimeType ==
            CurrencyTableController) {
      controller = GlobalCache.cacheMap["CurrencyTable"]![currentCacheID];
    }
  }

  @override
  void dispose() {
    controller.saveToMemory(
        GlobalCache.cacheMap["CurrencyTable"]!, currentCacheID);
    cacheID--;
    super.dispose();
  }

  void startEditing(int rowID) {
    editing = true;
    editingIndex = rowID;
    editingRow = controller.rows[rowID];
    parent!.setState(() {});
  }

  void completeEditing(String currencyName, Decimal currencyValue,
      {bool cancel = false}) {
    editing = false;
    editingRow![1] = currencyName;
    editingRow![2] = currencyValue;
    editingRow = null;
    parent!.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    parent = context.findAncestorStateOfType<CurrencyDbEditorState>();
    return Container(
      margin: EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children: [
          DataTable(
              horizontalMargin: 12,
              columnSpacing: 23,
              decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.all(Radius.circular(6))),
              columns: [
                for (var col in controller.columns)
                  DataColumn(label: Text(col.name)),
                DataColumn(label: SizedBox()),
              ],
              rows: _buildRows()),
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              setState(() {
                controller.addRow();
              });
            },
          ),
        ]),
      ),
    );
  }

  List<DataRow> _buildRows() {
    var rows = <DataRow>[];
    int i = 0;
    for (var row in controller.rows) {
      var tempCells = <DataCell>[];
      var tempI = i;
      for (var cell in row.rowData) {
        if (cell.runtimeType == String) {
          tempCells.add(DataCell(Text(cell as String)));
        } else {
          tempCells.add(DataCell(Text(cell.toString())));
        }
      }
      tempCells.add(DataCell(
        Row(children: [
          IconButton(
              icon: Icon(
                Icons.edit,
              ),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                startEditing(tempI);
              }),
          IconButton(
              icon: Icon(
                Icons.delete_outline,
              ),
              color: Colors.red[800],
              visualDensity: VisualDensity.compact,
              onPressed: () {
                setState(() {
                  controller.deleteRow(tempI);
                });
              }),
        ]),
      ));
      rows.add(DataRow(cells: tempCells));
      i++;
    }

    return rows;
  }
}
