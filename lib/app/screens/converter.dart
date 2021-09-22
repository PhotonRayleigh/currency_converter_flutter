import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
// import 'package:win32/win32.dart';
import 'package:decimal/decimal.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

import 'package:currency_converter_flutter/app/models/currencies.dart';
import 'package:currency_converter_flutter/app/app_system_manager.dart';

class ConverterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ConverterScreenState();
  }
}

// Todos:
// 1) Finish styling
// 2) Start hooking up conversion logic
// 3) Start on backend.

class ConverterScreenState extends State<ConverterScreen> {
  static const defaultSelection = "--SELECT--";
  static final defaultValue = Decimal.zero;
  String fromVal = defaultSelection;
  String toVal = defaultSelection;

  // double? submitButtonWidth;
  // var convertBtnKey = GlobalKey(debugLabel: "convert button key");

  var amtColKey = GlobalKey(debugLabel: "Amount Key");
  var height = 1.0;

  var enterAmountController = TextEditingController(text: "");
  var convertedOutput = Decimal.zero;
  var inputValue = Decimal.zero;

  @override
  void initState() {
    super.initState();

    void updateOnScreenResize() {
      height = amtColKey.currentContext?.size?.height ?? 1.0;
      // submitButtonWidth = convertBtnKey.currentContext?.size?.width;
      // print(height);
      setState(() {});
    }

    void addCallback() {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        updateOnScreenResize();
      });
    }

    addCallback();

    appManager.onScreenChanged.add(addCallback);
  }

  @override
  Widget build(BuildContext context) {
    double minWidth = context.isLandscape ? 497 : 216;

    Color textColor = Colors.white;
    TextStyle panelTextStyle = TextStyle(color: textColor, fontSize: 20);
    TextStyle darkTextStyle = TextStyle(color: Colors.black, fontSize: 20);

    LinearGradient panelGradient = LinearGradient(
        colors: [Color(0xFFec2075), Color(0xFFf33944)], stops: [0.0, 0.5]);

    // Axis inputBoxDir = context.isLandscape ? Axis.horizontal : Axis.vertical;

    var buttonDecoration = BoxDecoration(
      gradient: panelGradient,
      borderRadius: BorderRadius.all(Radius.circular(6)),
    );

    var inputBoxDivider = Divider(
      height: 12,
      color: Colors.transparent,
    );

    var enterAmountColumn = Column(
      key: amtColKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter Amount:",
          style: panelTextStyle,
        ),
        inputBoxDivider,
        TextField(
          controller: enterAmountController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.attach_money),
            hintText: "0.00",
            // constraints: BoxConstraints.loose(Size.fromWidth(context.width)),
          ),
          style: TextStyle(color: Colors.black),
          inputFormatters: [FormatNumericOnly()],
          onChanged: (text) {
            if (text == "") return;
            String cleanedText = text;
            var regExPattern = RegExp(r"(\d*[.]?\d{0,8}){1}");
            if (regExPattern.hasMatch(text)) {
              if (text.endsWith(".")) cleanedText = text + "0";
              if (text.startsWith(".")) cleanedText = "0" + text;
              var decimal = Decimal.parse(cleanedText);
              inputValue = Decimal.parse(cleanedText);
            } else
              print("Error: Incorrect number format.");
          },
        ),
      ],
    );

    var fromColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "From:",
          style: panelTextStyle,
          textAlign: TextAlign.start,
        ),
        inputBoxDivider,
        buildList(fromVal, (newVal) => fromVal = newVal, darkTextStyle),
      ],
    );

    var toColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "To:",
          style: panelTextStyle,
        ),
        inputBoxDivider,
        buildList(toVal, (newVal) => toVal = newVal, darkTextStyle),
      ],
    );

    List<Widget> inputCols;
    if (context.isLandscape) {
      inputCols = [
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(right: 6), child: enterAmountColumn)),
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 6, right: 6),
                child: fromColumn)),
        Column(children: [
          SizedBox(
            height: height,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Icon(
                  Icons.swap_horiz,
                  color: Colors.white,
                  size: 38,
                )),
          ),
          SizedBox(
            height: 10,
            width: 10,
          )
        ]),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(left: 6),
          child: toColumn,
        )),
      ];
    } else {
      inputCols = [
        Padding(
            padding: EdgeInsets.only(right: 0, bottom: 6),
            child: enterAmountColumn),
        Padding(padding: EdgeInsets.only(left: 0, right: 0), child: fromColumn),
        Column(children: [
          Padding(
              padding: EdgeInsets.only(top: 6, bottom: 6),
              child: Icon(
                Icons.swap_vert,
                color: Colors.white,
                size: 38,
              )),
        ]),
        Padding(
          padding: EdgeInsets.only(left: 0),
          child: toColumn,
        ),
      ];
    }

    // Contains main user input UI
    var selectorsBlock = Container(
      margin: EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        gradient: panelGradient,
      ),
      child: Flex(
        direction: context.isLandscape ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: inputCols,
      ),
    );

    return Scaffold(
      appBar: NewGradientAppBar(
        title: Text(
          "Currency Converter",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        gradient: panelGradient,
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
      body: InteractiveViewer(
        panEnabled: true,
        scaleEnabled: false,
        constrained: false,
        alignPanAxis: true,
        child: SizedBox(
            width: context.width > minWidth ? context.width : minWidth,
            height: null,
            child: Column(
              children: [
                Text(
                  "Converted Currency",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                Text(
                    "\$${() {
                      var tmp = convertedOutput.toStringAsFixed(8);
                      // if (!tmp.contains(".")) return tmp;
                      var index = tmp.length - 1;
                      int trimTo = index;
                      var chars = tmp.characters.toList();
                      for (int i = index; i >= 0; i--) {
                        // Iterate until we hit not zero or get within 2 places of the period.
                        if (chars[i] == '0') {
                          trimTo = i;
                        } else
                          break;
                        int toPeriod = 1;
                        for (int j = i; chars[j] != '.'; j--) toPeriod++;
                        if (toPeriod <= 3) break;
                      }
                      var finalList = chars.sublist(0, trimTo + 1);
                      String output = "";
                      for (var char in finalList) output = output + char;
                      return output;
                    }()}",
                    style: TextStyle(fontSize: 16)),
                selectorsBlock,
                FittedBox(
                    child: Row(
                  children: [
                    Container(
                        // key: convertBtnKey,
                        margin: EdgeInsets.all(6.0),
                        padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
                        decoration: buttonDecoration,
                        child: TextButton(
                          child: Text("Convert", style: panelTextStyle),
                          onPressed: calculateConversion,
                        )),
                    Container(
                      margin: EdgeInsets.all(6.0),
                      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      decoration: buttonDecoration,
                      child: TextButton(
                        child: Text(
                          "Clear",
                          style: panelTextStyle,
                        ),
                        onPressed: clearInputs,
                      ),
                    ),
                  ],
                )),
              ],
            )),
      ),
    );
  }

  Widget buildList(
      String selectedVal, void Function(String) update, TextStyle textStyle) {
    List<DropdownMenuItem<String>> dropDownItems = <DropdownMenuItem<String>>[];
    dropDownItems.add(DropdownMenuItem(
        child: Text(defaultSelection, style: null), value: defaultSelection));

    currencyList.forEach((currency, value) {
      dropDownItems.add(
        DropdownMenuItem(
            child: Text(
              currency,
              style: null,
              // strutStyle:
              // StrutStyle(forceStrutHeight: false, height: 0, leading: 0),
            ),
            value: currency),
      );
    });

    var output = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(6), bottom: Radius.circular(6)),
          color: Colors.white),
      child: Column(
        children: [
          DropdownButton<String>(
            isDense: false,
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() => update(newValue ?? defaultSelection));
            },
            value: selectedVal,
            items: dropDownItems,
            dropdownColor: Colors.white,
            underline: SizedBox.shrink(),
          ),
          Divider(
            height: 0,
            color: Colors.black54,
            thickness: 2,
          )
        ],
      ),
    );

    return output;
    // return DropdownButton<String>(
    //   isExpanded: true,
    //   onChanged: (String? newValue) {
    //     setState(() => update(newValue ?? defaultSelection));
    //   },
    //   value: selectedVal,
    //   items: dropDownItems,
    //   dropdownColor: Colors.white,
    //   isDense: true,
    //   // underline: Divider(
    //   //   color: Colors.transparent,
    //   // ),
    // );
  }

  void clearInputs() {
    fromVal = defaultSelection;
    toVal = defaultSelection;
    enterAmountController.clear();
    convertedOutput = Decimal.zero;
    setState(() {});
  }

  void calculateConversion() {
    if (fromVal == defaultSelection || toVal == defaultSelection) {
      print("Error: Please select a currency to convert to and from.");
      return;
    }
    var fromFactor = currencyList[fromVal] ?? Decimal.fromInt(1);
    var toFactor = currencyList[toVal] ?? Decimal.fromInt(1);

    convertedOutput = inputValue * (toFactor / fromFactor);
    setState(() {});
  }
}

class FormatNumericOnly extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    TextEditingValue result = newValue;
    // var regExPattern = RegExp(r"\d*[.]?\d{0,4}");
    // 16 digits before decimal, 8 after
    int position = 0;
    int period = -1;
    int postPeriod = 0;
    for (var char in newValue.text.characters) {
      if (!char.isNumericOnly && char != '.') {
        result = oldValue;
        break;
      }
      if (char == '.') {
        if (period == -1) {
          period = position;
        } else {
          result = oldValue;
          break;
        }
      }
      if (period == -1 && position >= 16) {
        result = oldValue;
        break;
      }
      if (postPeriod > 8) {
        result = oldValue;
        break;
      }

      position++;
      if (period >= 0) postPeriod++;
    }

    return result;
  }
}
