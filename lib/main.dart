import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';

// Imports local to this project should be listed after standard/pub libraries
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());

  // bitsdogo_window startup code.
  // This is required when using the bitsdojo package,
  // Window will not otherwise show.
  // REMINDER: Custom runner code setup required PER PLATFORM
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    doWhenWindowReady(() {
      final initialSize = Size(900, 600);
      final minSize = Size(200, 200);
      appWindow.size = initialSize;
      appWindow.minSize = minSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = "Currency Converter";
      appWindow.show();
    });
  }
}
