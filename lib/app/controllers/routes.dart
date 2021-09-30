import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../screens/converter.dart';
import '../screens/db_editor.dart';

class AppRoutes {
  static Widget home = ConverterScreen();

  static Widget converterScreen = home;
  static Widget currencyDbEditor = CurrencyDbEditor();
}
