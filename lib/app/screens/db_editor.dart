import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';

import 'package:spark_lib/navigation/spark_nav.dart';
import 'package:spark_lib/strings/text_formatters.dart';
import 'package:spark_lib/widgets/unfocuser.dart';

import 'package:currency_converter_flutter/app/widgets/app_bar.dart';
import 'package:currency_converter_flutter/app/widgets/nav_drawer.dart';
import '../theme/main_decorations.dart';
import '../data/currencies.dart';
import '../widgets/currency_table.dart';
import '../misc/clean_and_parse_decimal.dart';
import '../db_connections/mariadb_connector.dart';

class CurrencyDbEditor extends StatefulWidget {
  CurrencyDbEditor({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CurrencyDbEditorState();
  }
}

class CurrencyDbEditorState extends State<CurrencyDbEditor> {
  var currencyInput = TextEditingController();
  var valueInput = TextEditingController();
  var tableKey = GlobalKey<CurrencyTableState>();
  bool editing = false;

  @override
  void initState() {
    super.initState();

    AppNavigator.preNavCallbacks.add(
      () async {
        var tController = tableKey.currentState!.controller;
        if (tController.isDirty) {
          await tController.submitChanges().whenComplete(() {
            var data = sharedCurrencyData!;
            data.names = [];
            data.values = [];
            for (var row in tController.dataTable) {
              data.names.add(row["name"] as String);
              data.values.add(row["value"] as Decimal);
            }
          });
        } else {
          var data = sharedCurrencyData!;
          data.names = <String>[];
          data.values = <Decimal>[];
          for (var row in tController.dataTable) {
            data.names.add(row["name"] as String);
            data.values.add(row["value"] as Decimal);
          }
        }
      },
    );
  }

  void enterEditMode() {
    var tableState = tableKey.currentState!;
    currencyInput.text = tableState.editingRow!["name"] as String;
    valueInput.text = tableState.editingRow!["value"].toString();
    editing = true;
  }

  @override
  Widget build(BuildContext context) {
    var tableState = tableKey.currentState;
    bool editMode = tableState?.editing ?? false;
    if (editMode && !editing) {
      enterEditMode();
    }

    bool tableDirty = tableState?.controller.isDirty ?? false;

    void Function()? updateButton;
    void Function()? cancelButton;

    if (editing) {
      updateButton = () {
        var name = currencyInput.text;
        var value = cleanAndParseDecimal(valueInput.text);
        if (value == null) {
          print("Error: Failed to parse decimal input.");
          return;
        }
        var tableState = tableKey.currentState!;
        tableState.completeEditing(name, value);
        setState(() {
          editing = false;
          currencyInput.clear();
          valueInput.clear();
        });
      };

      cancelButton = () {
        tableKey.currentState!.cancelEditing();
        setState(() {
          editing = false;
          currencyInput.clear();
          valueInput.clear();
        });
      };
    }

    var retryDbConnButton = TextButton(
        onPressed: () async {
          if (mariaDBConnector.connection == null) {
            var check = await mariaDBConnector.initializeConnection();
            if (check) {
              print("MariaDB Connection Established");
            } else {
              print("MariaDB Connection Failed");
            }
          }
        },
        child: Text(
          "Retry DB Connection",
          style: panelTextStyle,
        ));

    var printDbConnButton = TextButton(
        onPressed: () async {
          var conn = mariaDBConnector.connection!;
          var data = await conn.query('SELECT * FROM currency_list');
          for (var row in data) {
            print(
                "${data.fields[0].name}: ${row[0]}, ${data.fields[1].name}: ${row[1]}, ${data.fields[2].name}: ${row[2]}");
          }
        },
        child: Text(
          "Print DB Info",
          style: panelTextStyle,
        ));

    var submitButtons = FittedBox(
        child: Row(
      children: [
        // Convert Button
        Container(
          margin: EdgeInsets.all(6.0),
          padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
          decoration: buttonDecoration,
          child: TextButton(
              child: Text("Update", style: panelTextStyle),
              onPressed: updateButton),
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
            onPressed: cancelButton,
          ),
        ),
        // if (mariaDBConnector.connection == null)
        //   Container(
        //     margin: EdgeInsets.all(6.0),
        //     padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
        //     decoration: buttonDecoration,
        //     child: retryDbConnButton,
        //   ),
        // if (mariaDBConnector.connection != null)
        //   Container(
        //     margin: EdgeInsets.all(6.0),
        //     padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
        //     decoration: buttonDecoration,
        //     child: printDbConnButton,
        //   ),
      ],
    ));

    var enterCurrencyField = TextField(
      controller: currencyInput,
      decoration: InputDecoration(fillColor: onPanelFgColor, filled: true),
      inputFormatters: [FormatCurrencyAlphabetic()],
      enabled: editing,
    );

    var enterAmountField = TextField(
      controller: valueInput,
      decoration: InputDecoration(fillColor: onPanelFgColor, filled: true),
      inputFormatters: [FormatCurrencyNumeric()],
      enabled: editing,
    );

    var inputsPanel = Container(
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
                enterCurrencyField,
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
                enterAmountField,
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );

    return SparkPage(
        child: Unfocuser(
            child: Scaffold(
      appBar: customAppBar(
        context,
        tableDirty,
        titleText: "Database Editor",
      ),
      body: Column(
        children: [
          inputsPanel,
          submitButtons,
          Expanded(
            child: CurrencyTable(
              key: tableKey,
              bgColor: Colors.blueGrey[100]!,
            ),
          ),
        ],
      ),
      drawer: tableDirty ? null : NavDrawer(),
    )));
  }

  NewGradientAppBar customAppBar(BuildContext context, bool tableDirty,
      {Key? key, required titleText}) {
    Widget appBarTitle;
    List<Widget> appBarActions = [];
    WindowButtonColors windowButtonColors =
        WindowButtonColors(iconNormal: Colors.white, mouseOver: Colors.black38);

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      appBarActions = [
        // IconButton(
        //   onPressed: () {
        //     AppNavigator.defaultBack();
        //   },
        //   icon: Icon(Icons.arrow_back),
        //   color: Colors.amber[300],
        // ),
        if (AppNavigator.currentView != AppNavigator.homeScreen)
          tableDirty
              ? Row(
                  children: [
                    TextButton(
                      child: Text("Save"),
                      onPressed: () {
                        var tableState = tableKey.currentState;
                        tableState!.controller
                            .submitChanges()
                            .whenComplete(() => setState(() {}));
                      },
                    ),
                    TextButton(
                        child: Text("Discard"),
                        onPressed: () {
                          var tableState = tableKey.currentState;
                          tableState!.controller.discardChanges();
                          setState(() {});
                        })
                  ],
                )
              : IconButton(
                  onPressed: () {
                    AppNavigator.navigateBack();
                  },
                  icon: Icon(Icons.arrow_back),
                ),
        MinimizeWindowButton(
          colors: windowButtonColors,
        ),
        MaximizeWindowButton(colors: windowButtonColors),
        CloseWindowButton(
            colors: WindowButtonColors(
                iconNormal: Colors.white,
                mouseOver: Colors.pink[900]?.withOpacity(0.65),
                mouseDown: Colors.pink[200])),
      ];
      appBarTitle =
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
            child: MoveWindow(
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      titleText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            Theme.of(context).textTheme.headline5?.fontSize,
                      ),
                    ))))
      ]);
    } else {
      appBarTitle = Text(
        titleText,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: Theme.of(context).textTheme.headline5?.fontSize,
        ),
      );
      appBarActions = tableDirty
          ? [
              Row(
                children: [
                  TextButton(
                    child: Text("Save"),
                    onPressed: () {
                      var tableState = tableKey.currentState;
                      tableState!.controller
                          .submitChanges()
                          .whenComplete(() => setState(() {}));
                    },
                  ),
                  TextButton(
                      child: Text("Discard"),
                      onPressed: () {
                        var tableState = tableKey.currentState;
                        tableState!.controller.discardChanges();
                        setState(() {});
                      })
                ],
              )
            ]
          : [];
    }

    return NewGradientAppBar(
      title: appBarTitle,
      gradient: panelGradient,
      actions: appBarActions,
    );
  }
}
