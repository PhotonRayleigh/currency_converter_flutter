import 'package:currency_converter_flutter/app/controllers/app_navigator.dart';
import 'package:flutter/material.dart';

import 'package:currency_converter_flutter/app/widgets/app_bar.dart';
import 'package:currency_converter_flutter/app/widgets/nav_drawer.dart';

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
    return WillPopScope(
        onWillPop: AppNavigator.defaultOnWillPop,
        child: Scaffold(
          appBar: MainAppBar.build(context, titleText: "Database Editor"),
          body: Center(
            child: Text("Placeholder"),
          ),
          drawer: NavDrawer(),
        ));
  }
}
