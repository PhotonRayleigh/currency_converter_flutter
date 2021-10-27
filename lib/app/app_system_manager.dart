import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'db_connections/mariadb_connector.dart';
import 'db_connections/sqlite_connector.dart';

/*
    AppSystemManager class:
    This class provides top level control of the application
    as well as the ability to respond to system events.

    I suppose this is also a good place to run tasks not dependent
    on the UI loop, such as listening services.

    Later, I should probably implement ChangeNotifier to propagate
    changes to the UI tree in response to external events.

    I think this widget is similar to my Main node that I typically
    use in Godot applications.
*/

late final _AppSystemManagerState appManager;
late bool _managerSet = false;

class AppSystemManager extends StatefulWidget {
  final Widget child;
  AppSystemManager({Key? key, required this.child}) : super(key: key);
  @override
  _AppSystemManagerState createState() => _AppSystemManagerState();
}

class _AppSystemManagerState extends State<AppSystemManager>
    with WidgetsBindingObserver {
  _AppSystemManagerState() {
    if (_managerSet)
      throw Exception(
          "Error: Apps can only have one AppSystemManager instanced");
    appManager = this;
  }

  List<void Function()> _onScreenChanged = <void Function()>[];
  void addScreenChanged(void Function() callback) {
    // prevent duplicate entries
    if (_onScreenChanged.contains(callback))
      return;
    else
      _onScreenChanged.add(callback);
  }

  void removeScreenChanged(void Function() callback) =>
      _onScreenChanged.remove(callback);

  // List<void Function()> _onShutdown = <void Function()>[];
  // void addOnShutdown(void Function() callback) {
  //   // prevent duplicate entries
  //   if (_onShutdown.contains(callback))
  //     return;
  //   else
  //     _onShutdown.add(callback);
  // }

  // void removeOnShutdown(void Function() callback) =>
  //     _onShutdown.remove(callback);

  @override
  initState() {
    // Use init state for system initialization tasks, I think
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance!.addObserver(this);

    if (useMariaDB) {
      var completer = mariaDBConnector.initializeConnection();
      completer.then((value) {
        if (value) {
          print("MariaDB connection established");
        } else {
          print("MariaDB connection failed");
        }
      });
    }

    sqliteConnector.openDB();

    Get.put(this);
  }

  // Doesn't seem to work :/ 10/5/2021
  // Future _setupShutdown() async {
  //   Shutdown.triggerOnSigHup();
  //   Shutdown.triggerOnSigInt();

  //   Shutdown.addHandler(() async {
  //     for (var callback in _onShutdown) {
  //       callback();
  //     }
  //   });

  //   await Shutdown.shutdown();
  // }

  @override
  void dispose() async {
    // Clean up operations can go in the dispose section
    mariaDBConnector.closeConnection();
    sqliteConnector.closeDB();
    Get.delete<_AppSystemManagerState>();
    WidgetsBinding.instance!.removeObserver(this);
    super
        .dispose(); // Remember super.dispose always comes last in dispose methods.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // The cases provided by Flutter don't cover all system possibilities.
    // For example, if the app is terminated, I might need to write some
    // finalizing code in Kotlin for Android, and might need something special
    // in Swift for iOS.
    switch (state) {
      case AppLifecycleState.inactive:
        print('inactive');
        break;
      case AppLifecycleState.paused:
        print('paused');
        break;
      case AppLifecycleState.resumed:
        print('resumed');
        break;
      case AppLifecycleState.detached:
        print('detached');
        break;
      default:
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // print('rotated');
    // This actually gets called every time the view is resized.
    // There are other ways to handle screen size changes, which may be better suited
    // than using this callback.
    for (var action in _onScreenChanged) {
      action();
    }
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();

    print('low memory');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
