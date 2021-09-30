import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:currency_converter_flutter/app/screens/db_editor.dart';
import 'package:currency_converter_flutter/app/controllers/app_navigator.dart';
import 'package:currency_converter_flutter/app/screens/converter.dart';

class NavDrawer extends StatelessWidget {
  NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Text("Navigation"),
          ),
          Expanded(
              child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              ListTile(
                  title: Text("Currency Converter"),
                  onTap: () {
                    if (AppNavigator.currentView is ConverterScreen) {
                      AppNavigator.rootNavigator.pop();
                      return;
                    }
                    AppNavigator.navigateTo(ConverterScreen());
                  }),
              ListTile(
                  title: Text("Database Editor"),
                  onTap: () {
                    if (AppNavigator.currentView is CurrencyDbEditor) {
                      AppNavigator.rootNavigator.pop();
                      return;
                    }
                    AppNavigator.navigateTo(CurrencyDbEditor());
                  }),
            ],
          ))
        ],
      ),
    );
  }
}
