import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return SparkPage(
        child: Scaffold(
      appBar: MainAppBar.build(context, titleText: "Database Editor"),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(20, 8, 20, 8),
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                    decoration: BoxDecoration(color: Colors.blueGrey[100]),
                    columns: [
                      DataColumn(label: Text("Currency")),
                      DataColumn(label: Text("Value")),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text("USD")),
                        DataCell(Text("1.00")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("USD")),
                        DataCell(Text("1.00")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("USD")),
                        DataCell(Text("1.00")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("USD")),
                        DataCell(Text("1.00")),
                      ]),
                      DataRow(cells: [
                        DataCell(Text("USD")),
                        DataCell(Text("1.00")),
                      ]),
                    ]),
              ),
            ),
          ),
        ],
      ),
      drawer: NavDrawer(),
    ));
  }
}
