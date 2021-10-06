import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import 'package:spark_lib/navigation/spark_nav.dart';
import 'package:spark_lib/data/cache.dart';
import 'package:spark_lib/strings/text_formatters.dart';

import 'package:currency_converter_flutter/app/widgets/app_bar.dart';
import 'package:currency_converter_flutter/app/widgets/nav_drawer.dart';
import '../theme/main_decorations.dart';
import '../models/currencies.dart';
import '../controllers/currency_table_controller.dart';
import '../widgets/currency_table.dart';

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

  void enterEditMode() {
    var tableState = tableKey.currentState!;
    currencyInput.text = tableState.editingRow![1] as String;
    valueInput.text = tableState.editingRow![2].toString();
    editing = true;
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Add code to check for editing mode and set the UI accordingly
    bool editMode = tableKey.currentState?.editing ?? false;
    if (editMode && !editing) {
      enterEditMode();
    }

    void updateButton() {
      if (editing) {
        //
      }
    }

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

    var enterCurrencyField = TextField(
      controller: currencyInput,
      decoration: InputDecoration(fillColor: onPanelFgColor, filled: true),
      inputFormatters: [FormatCurrencyAlphabetic()],
    );

    var enterAmountField = TextField(
      controller: valueInput,
      decoration: InputDecoration(fillColor: onPanelFgColor, filled: true),
      inputFormatters: [FormatCurrencyNumeric()],
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
        child: Scaffold(
      appBar: MainAppBar.build(context, titleText: "Database Editor"),
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
      drawer: NavDrawer(),
    ));
  }
}
