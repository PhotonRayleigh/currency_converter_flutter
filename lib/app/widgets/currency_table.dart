import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import '../controllers/currency_table_controller.dart';
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
      this.controller = CurrencyTableController();
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
  MapRow? editingRow;

  @override
  void initState() {
    super.initState();
    currentCacheID = cacheID;
    cacheID++;

    controller = widget.controller;
    // if (!GlobalCache.cacheMap.containsKey("CurrencyTable")) {
    //   GlobalCache.cacheMap["CurrencyTable"] = Cache<CurrencyTableController>();
    // } else if (GlobalCache.cacheMap["CurrencyTable"]![currentCacheID] != null ||
    //     GlobalCache.cacheMap["CurrencyTable"]![currentCacheID].runtimeType ==
    //         CurrencyTableController) {
    //   controller = GlobalCache.cacheMap["CurrencyTable"]![currentCacheID];
    // }
    controller.initialize().whenComplete(() => setState(() {}));

    // this.controller.importFromDB().whenComplete(() => setState(() {}));
  }

  @override
  void dispose() {
    // controller.saveToMemory(
    //     GlobalCache.cacheMap["CurrencyTable"]!, currentCacheID);
    cacheID--;
    super.dispose();
  }

  void startEditing(int rowID) {
    editing = true;
    editingIndex = rowID;
    editingRow = controller.dataTable[rowID];
    parent!.setState(() {});
  }

  void completeEditing(String currencyName, Decimal currencyValue) {
    editing = false;
    controller.updateRow(editingIndex, currencyName, currencyValue);
    // mariaDBConnector.updateRow(
    //     editingRow![0] as int, currencyName, currencyValue);
    editingRow = null;
  }

  void cancelEditing() {
    editing = false;
    editingRow = null;
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
                DataColumn(label: Text("name")),
                DataColumn(label: Text("value")),
                DataColumn(label: SizedBox()),
              ],
              rows: _buildRows()),
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              controller.addRow(newRow: {
                "name": "null",
                "value": Decimal.zero
              }).whenComplete(() {
                parent!.setState(() {});
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
    for (var row in controller.dataTable) {
      var tempCells = <DataCell>[];
      var tempI = i;
      tempCells.add(DataCell(Text(row["name"] as String)));
      tempCells.add(DataCell(Text((row["value"] as Decimal).toString())));
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
                parent!.setState(() {
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
