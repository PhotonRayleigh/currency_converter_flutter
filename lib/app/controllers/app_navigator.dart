import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:collection';
import 'package:back_button_interceptor/back_button_interceptor.dart';

// The default Flutter navigator is annoying.
// It provides basically nothing outside of the build tree
// to access the current route info with.
// And if you get the current route, good luck getting
// your root Widget or learning anything about it.
// This is causing me a lot of pain, the default Navigator
// seems pretty lousy to me. I'd almost rather not use it,
// but the default MaterialApp forces me to.

class AppNavigator {
  static NavigatorState? _rootNavigator;
  static NavigatorState get rootNavigator {
    if (_rootNavigator == null) {
      return rootNavKey.currentState!;
    } else
      return _rootNavigator!;
  }

  static set rootNavigator(val) {
    _rootNavigator = val;
  }

  static GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>();

  static late Widget homeScreen;
  static Queue<Widget> screenStack = Queue<Widget>();
  static get currentView => screenStack.last;

  static bool popupOpen = false;

  static initialize({required home}) {
    AppNavigator.homeScreen = home;
    screenStack.add(AppNavigator.homeScreen);

    bool navigationOverride(bool stopDefaultbuttonEvent, RouteInfo info) {
      if (screenStack.length == 1) return false;
      navigateBack();
      return true;
    }

    // WARNING: This will break backing out of popups.
    BackButtonInterceptor.add(navigationOverride);
  }

  static void navigateTo(Widget screen, {BuildContext? context}) {
    screenStack.add(screen);
    rootNavigator.pushReplacement(MaterialPageRoute(
      builder: (context) {
        return screen;
      },
    ));
  }

  static void navigateBack({BuildContext? context}) {
    if (screenStack.length == 1) return;
    screenStack.removeLast();
    rootNavigator.pushReplacement(MaterialPageRoute(
      builder: (context) {
        return screenStack.last;
      },
    ));
    // if (rootNavigator.canPop()) rootNavigator.pop();
  }

  static void defaultBack() {
    if (rootNavigator.canPop()) rootNavigator.pop();
  }
}
