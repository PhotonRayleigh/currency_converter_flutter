import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:spark_lib/navigation/app_navigator.dart';

import 'package:currency_converter_flutter/app/screens/db_editor.dart';
import 'package:currency_converter_flutter/app/screens/converter.dart';
import '../controllers/routes.dart';

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
              if (AppNavigator.currentView != AppRoutes.converterScreen)
                ListTile(
                    title: Text("Currency Converter"),
                    onTap: () {
                      if (AppNavigator.currentView is ConverterScreen) {
                        AppNavigator.safePop();
                        return;
                      }
                      AppNavigator.navigateTo(AppRoutes.converterScreen);
                    }),
              if (AppNavigator.currentView != AppRoutes.currencyDbEditor)
                ListTile(
                    title: Text("Database Editor"),
                    onTap: () {
                      if (AppNavigator.currentView is CurrencyDbEditor) {
                        AppNavigator.safePop();
                        return;
                      }
                      AppNavigator.navigateTo(AppRoutes.currencyDbEditor);
                    }),
            ],
          ))
        ],
      ),
    );
  }
}
