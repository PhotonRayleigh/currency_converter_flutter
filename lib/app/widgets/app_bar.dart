import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

import 'package:spark_lib/navigation/app_navigator.dart';

import 'package:currency_converter_flutter/app/theme/main_decorations.dart';

class MainAppBar {
  static NewGradientAppBar build(BuildContext context,
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
          IconButton(
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
    }

    return NewGradientAppBar(
      title: appBarTitle,
      gradient: panelGradient,
      actions: appBarActions,
    );
  }
}
