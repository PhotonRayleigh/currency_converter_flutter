import 'package:flutter/material.dart';

import 'package:spark_lib/widgets/shift_right_fixer.dart';

import 'package:currency_converter_flutter/app/screens/converter.dart';
import 'package:currency_converter_flutter/app/app_system_manager.dart';

// TODO: add additional wrappers required for fixes and additional functionality.

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShiftRightFixer(
        child: AppSystemManager(
            child: MaterialApp(
      home: ConverterScreen(),
    )));
  }
}

// My mentality lately has been, I know what my interest are. 
