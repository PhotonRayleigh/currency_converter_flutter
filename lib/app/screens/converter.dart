import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:decimal/decimal.dart';

import 'package:currency_converter_flutter/app/models/currencies.dart';

class ConverterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ConverterScreenState();
  }
}

// TODO: Implement

class ConverterScreenState extends State<ConverterScreen> {
  static const defaultSelection = "--SELECT--";
  static final defaultValue = Decimal.zero;
  String fromVal = defaultSelection;
  String toVal = defaultSelection;

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.white;
    TextStyle panelTextStyle = TextStyle(color: textColor, fontSize: 20);
    TextStyle darkTextStyle = TextStyle(color: Colors.black, fontSize: 20);

    LinearGradient panelGradient = LinearGradient(
        colors: [Color(0xFFec2075), Color(0xFFf33944)], stops: [0.0, 0.5]);

    var buttonDecoration = BoxDecoration(
      gradient: panelGradient,
      borderRadius: BorderRadius.all(Radius.circular(6)),
    );

    var selectorsBlock = Container(
      margin: EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          gradient: panelGradient),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
              child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    "Enter Amount:",
                    style: panelTextStyle,
                  )),
              Padding(
                  padding: EdgeInsets.all(4),
                  child: TextField(
                    controller: TextEditingController(text: "0.00"),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.attach_money)),
                    style: TextStyle(color: Colors.black),
                  )),
            ],
          )),
          Expanded(
            child: Column(
              children: [
                Text(
                  "From:",
                  style: panelTextStyle,
                ),
                buildList(fromVal, (newVal) => fromVal = newVal, darkTextStyle),
              ],
            ),
          ),
          Icon(Icons.swap_horiz),
          Expanded(
            child: Column(
              children: [
                Text(
                  "To:",
                  style: panelTextStyle,
                ),
                buildList(toVal, (newVal) => toVal = newVal, darkTextStyle),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Currency Converter"),
        backgroundColor: Color(0xFFF33845),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Text("Placeholder"),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Text("Converted Currency"),
            Text(""),
            selectorsBlock,
            FittedBox(
                child: Row(
              children: [
                Container(
                    margin: EdgeInsets.all(6.0),
                    padding: EdgeInsets.all(4),
                    decoration: buttonDecoration,
                    child: TextButton(
                      child: Text("Convert", style: panelTextStyle),
                      onPressed: () {},
                    )),
                Container(
                  margin: EdgeInsets.all(6.0),
                  padding: EdgeInsets.all(4),
                  decoration: buttonDecoration,
                  child: TextButton(
                    child: Text(
                      "Clear",
                      style: panelTextStyle,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget buildList(
      String selectedVal, void Function(String) update, TextStyle textStyle) {
    List<DropdownMenuItem<String>> dropDownItems = <DropdownMenuItem<String>>[];
    dropDownItems.add(DropdownMenuItem(
        child: Text(defaultSelection, style: textStyle),
        value: defaultSelection));

    currencyList.forEach((currency, value) {
      dropDownItems.add(
        DropdownMenuItem(
            child: Text(
              currency,
              style: textStyle,
            ),
            value: currency),
      );
    });

    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6), color: Colors.white),
        child: DropdownButton<String>(
          onChanged: (String? newValue) {
            setState(() => update(newValue ?? defaultSelection));
          },
          value: selectedVal,
          items: dropDownItems,
          dropdownColor: Colors.white,
        ));
  }
}
