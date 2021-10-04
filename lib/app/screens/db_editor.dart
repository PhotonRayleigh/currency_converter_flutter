import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import 'package:spark_lib/navigation/spark_nav.dart';

import 'package:currency_converter_flutter/app/widgets/app_bar.dart';
import 'package:currency_converter_flutter/app/widgets/nav_drawer.dart';
import '../theme/main_decorations.dart';

// Bug: On hot-reload, it invalidates my navigation scheme.
// Probably best to used a named route system instead of relying on object equality.
// I'll want to take some time to upgrade my navigation code at some point.

class CurrencyDbEditor extends StatefulWidget {
  CurrencyDbEditor({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CurrencyDbEditorState();
  }
}

class CurrencyDbEditorState extends State<CurrencyDbEditor> {
  var submitButtons = FittedBox(
      child: Row(
    children: [
      // Convert Button
      Container(
        margin: EdgeInsets.all(6.0),
        padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
        decoration: buttonDecoration,
        child: TextButton(
            child: Text("Update", style: panelTextStyle), onPressed: () {}),
      ),
      // Clear Button
      Container(
        margin: EdgeInsets.all(6.0),
        padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: buttonDecoration,
        child: TextButton(
          child: Text(
            "Cancel",
            style: panelTextStyle,
          ),
          onPressed: () {},
        ),
      ),
    ],
  ));

  @override
  Widget build(BuildContext context) {
    return SparkPage(
        child: Scaffold(
      appBar: MainAppBar.build(context, titleText: "Database Editor"),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(20, 8, 20, 8),
            padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              gradient: panelGradient,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Enter Currency:",
                            style: panelTextStyle,
                          )),
                      SizedBox(
                        height: 6,
                      ),
                      TextField(
                        decoration: InputDecoration(
                            fillColor: onPanelFgColor, filled: true),
                      )
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Enter Amount:",
                          style: panelTextStyle,
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      TextField(
                        decoration: InputDecoration(
                            fillColor: onPanelFgColor, filled: true),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ),
          submitButtons,
          Expanded(
            child: CurrencyTable(
              bgColor: Colors.blueGrey[100]!,
            ),
          ),
        ],
      ),
      drawer: NavDrawer(),
    ));
  }
}

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
        ColumnDefinition<String>("Currency", ""),
        ColumnDefinition<Decimal>("Value", Decimal.zero),
      ];

      this.controller = CurrencyTableController(cols);

      var testRows = [
        [0, "USD", Decimal.parse("12")],
        [1, "EUR", Decimal.parse("14")],
        [2, "RUB", Decimal.parse("6")],
      ];

      this.controller.setRows(testRows);
    } else
      this.controller = controller;
  }

  @override
  State<StatefulWidget> createState() {
    return CurrencyTableState();
  }
}

class CurrencyTableState extends State<CurrencyTable> {
  late CurrencyTableController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
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
    for (var row in controller.rows) {
      var tempCells = <DataCell>[];
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
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.delete_forever_outlined,
              ),
              color: Colors.red[800],
              visualDensity: VisualDensity.compact,
              onPressed: () {}),
        ]),
      ));
      rows.add(DataRow(cells: tempCells));
    }

    return rows;
  }
}

class CurrencyTableController {
  List<ColumnDefinition> columns = <ColumnDefinition>[];
  List<TableRow> rows = <TableRow>[];

  CurrencyTableController(this.columns);

  void setRows(List<List<Object>> newRows) {
    rows = <TableRow>[];
    for (var newRow in newRows) {
      rows.add(TableRow(columns, newRow));
    }
  }

  void addRow({List<Object>? newRow}) {
    if (newRow != null)
      rows.add(TableRow(columns, newRow));
    else {
      List<Object> tempList = <Object>[];
      for (var col in columns) {
        if (col.name.toUpperCase() == "ID" && col.type == int) {
          tempList.add(col.defaultVal + rows.length);
        } else
          tempList.add(col.defaultVal);
      }
      rows.add(TableRow(columns, tempList));
    }
  }
}

class ColumnDefinition<T> {
  String name = "";
  Type type = T;
  T defaultVal;

  ColumnDefinition(this.name, this.defaultVal);
}

class TableRow {
  List<ColumnDefinition> columns;
  late List<Object> rowData;

  TableRow(this.columns, List<Object> data) {
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
}
