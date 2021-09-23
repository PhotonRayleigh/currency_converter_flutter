import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:spark_lib/widgets/shift_right_fixer.dart';

import 'package:currency_converter_flutter/app/screens/converter.dart';
import 'package:currency_converter_flutter/app/app_system_manager.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShiftRightFixer(
        child: AppSystemManager(
            child: WindowBorder(
                color: Colors.black,
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: ConverterScreen(),
                ))));
  }
}
