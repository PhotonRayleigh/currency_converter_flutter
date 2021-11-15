import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
// import 'package:win32/win32.dart';
import 'package:decimal/decimal.dart';

import 'package:spark_lib/strings/text_formatters.dart';
import 'package:spark_lib/navigation/spark_nav.dart';
import 'package:spark_lib/widgets/unfocuser.dart';

import 'package:currency_converter_flutter/app/data/currencies.dart';
import 'package:currency_converter_flutter/app/app_system_manager.dart';
import 'package:currency_converter_flutter/app/theme/main_decorations.dart';
import 'package:currency_converter_flutter/app/widgets/app_bar.dart';
import 'package:currency_converter_flutter/app/widgets/nav_drawer.dart';
import '../misc/clean_and_parse_decimal.dart';

// Reminder: Flutter wrap plugin lets you use ALT-C to wrap a selection in a container,
// and ALT-S to wrap a selection in a stack.

// Openexchangerates.org base path: https://openexchangerates.org/api/
// Get request: https://openexchangerates.org/api/latest.json?app_id=02213fccad46472d8934f3fb57519a6d

// TODO: I think I need to add the permission for internet access to this project
// for the api request to work in release mode.

class ConverterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ConverterScreenState();
  }
}

class ConverterScreenState extends State<ConverterScreen> {
  static const defaultSelection = "--SELECT--";
  static final defaultValue = Decimal.zero;
  String fromVal = defaultSelection;
  String toVal = defaultSelection;

  late FocusNode _bgNode;

  // double? submitButtonWidth;
  // var convertBtnKey = GlobalKey(debugLabel: "conv ert button key");

  var amtColKey = GlobalKey(debugLabel: "Amount Key");
  var height = 1.0;

  var enterAmountController = TextEditingController(text: "");
  var convertedOutput = Decimal.zero;
  var inputValue = Decimal.zero;

  static const double _minWidthLandscape = 497;
  static const double _minWidthPortrait = 216;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  CurrencyData? currencyData;

  void useScaffoldKey() {}

  @override
  void initState() {
    super.initState();

    if (sharedCurrencyData == null) {
      sharedCurrencyData = CurrencyData();
    }
    currencyData = sharedCurrencyData;
    currencyData!.fetchingData.whenComplete(() => setState(() {}));

    _bgNode = FocusNode();

    _addCallback();

    appManager.addScreenChanged(_addCallback);
  }

  void _updateOnScreenResize() {
    height = amtColKey.currentContext?.size?.height ?? 1.0;
    // submitButtonWidth = convertBtnKey.currentContext?.size?.width;
    // print(height);
    setState(() {});
  }

  void _addCallback() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _updateOnScreenResize();
    });
  }

  @override
  void dispose() {
    appManager.removeScreenChanged(_addCallback);
    _bgNode.dispose();
    super.dispose();
  }

  void _clearInputs() {
    fromVal = defaultSelection;
    toVal = defaultSelection;
    enterAmountController.clear();
    convertedOutput = Decimal.zero;
    setState(() {});
  }

  void _calculateConversion() {
    if (fromVal == defaultSelection || toVal == defaultSelection) {
      print("Error: Please select a currency to convert to and from.");
      return;
    }
    var fromFactor =
        currencyData?.values[currencyData!.names.indexOf(fromVal)] ??
            Decimal.fromInt(1);
    var toFactor = currencyData?.values[currencyData!.names.indexOf(toVal)] ??
        Decimal.fromInt(1);

    convertedOutput = inputValue * (toFactor / fromFactor);
    setState(() {});
  }

  void _submitEnterAmount(String text) {
    if (text == "") return;
    var val = cleanAndParseDecimal(text);
    if (val != null) {
      inputValue = val;
    } else
      print("Error: Incorrect number format.");
  }

  String _formatCurrencyOutput() {
    var lead = toVal == defaultSelection ? "" : toVal + " ";

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
    return lead + output;
  }

  @override
  Widget build(BuildContext context) {
    double minWidth =
        context.isLandscape ? _minWidthLandscape : _minWidthPortrait;

    var convertClearButtons = FittedBox(
        child: Row(
      children: [
        // Convert Button
        Container(
            margin: EdgeInsets.all(6.0),
            padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
            decoration: buttonDecoration,
            child: TextButton(
              child: Text("Convert", style: panelTextStyle),
              onPressed: _calculateConversion,
            )),
        // Clear Button
        Container(
          margin: EdgeInsets.all(6.0),
          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
          decoration: buttonDecoration,
          child: TextButton(
            child: Text(
              "Clear",
              style: panelTextStyle,
            ),
            onPressed: _clearInputs,
          ),
        ),
      ],
    ));

    var primaryDisplayColumn = Column(
      children: [
        Text(
          "Converted Currency",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        Text(_formatCurrencyOutput(), style: TextStyle(fontSize: 16)),
        _buildUserInputPanel(context),
        convertClearButtons,
        Container(
            margin: EdgeInsets.all(6.0),
            padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
            decoration: buttonDecoration,
            child: TextButton(
              child: Text("Refresh Database", style: panelTextStyle),
              onPressed: () async {
                await currencyData!
                    .updateFromInternet()
                    .whenComplete(() => setState(() {}));
              },
            )),
      ],
    );

    return SparkPage(
        child: Unfocuser(
      child: Scaffold(
          key: scaffoldKey,
          appBar: MainAppBar.build(
            context,
            titleText: "Currency Converter",
          ),
          drawer: NavDrawer(),
          body: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: false,
            constrained: false,
            alignPanAxis: true,
            child: SizedBox(
                width: context.width > minWidth ? context.width : minWidth,
                height: null,
                child: primaryDisplayColumn),
          )),
    ));
  }

  Widget _buildList(
      String selectedVal, void Function(String) update, TextStyle textStyle) {
    List<DropdownMenuItem<String>> dropDownItems = <DropdownMenuItem<String>>[];
    dropDownItems.add(DropdownMenuItem(
        child: Text(defaultSelection, style: null), value: defaultSelection));

    if (currencyData != null && currencyData!.ready) {
      for (int i = 0; i < currencyData!.names.length; i++) {
        dropDownItems.add(DropdownMenuItem(
            child: Text(
              currencyData!.names[i],
              style: null,
              // strutStyle:
              // StrutStyle(forceStrutHeight: false, height: 0, leading: 0),
            ),
            value: currencyData!.names[i]));
      }
    }

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
  }

  List<Widget> _buildUserInputColumns(BuildContext context) {
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
          inputFormatters: [FormatCurrencyNumeric()],
          onChanged: _submitEnterAmount,
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
        _buildList(fromVal, (newVal) => fromVal = newVal, bgTextStyle),
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
        _buildList(toVal, (newVal) => toVal = newVal, bgTextStyle),
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

    return inputCols;
  }

  Widget _buildUserInputPanel(BuildContext context) {
    // Main user UI block
    return Container(
      margin: EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        gradient: panelGradient,
      ),
      child: Flex(
        direction: context.isLandscape ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _buildUserInputColumns(context),
      ),
    );
  }
}
