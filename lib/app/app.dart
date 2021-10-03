import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';

import 'package:spark_lib/widgets/shift_right_fixer.dart';
import 'package:spark_lib/navigation/app_navigator.dart';

import 'package:currency_converter_flutter/app/screens/converter.dart';
import 'package:currency_converter_flutter/app/app_system_manager.dart';
import 'controllers/routes.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppNavigator.initialize(home: AppRoutes.converterScreen);

    var materialApp = MaterialApp(
      navigatorKey: AppNavigator.rootNavKey,
      debugShowCheckedModeBanner: false,
      home: AppRoutes.converterScreen,
    );

    Widget sysManagerChild;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sysManagerChild =
          WindowBorder(color: Colors.blueGrey, width: 1, child: materialApp);
    } else {
      sysManagerChild = materialApp;
    }

    return ShiftRightFixer(child: AppSystemManager(child: sysManagerChild));
  }
}
