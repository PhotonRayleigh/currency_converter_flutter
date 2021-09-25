import 'package:flutter/material.dart';

Color onPanelFgColor = Colors.white;
Color onBgFgColor = Colors.black;
LinearGradient panelGradient = LinearGradient(
    colors: [Color(0xFFec2075), Color(0xFFf33944)], stops: [0.0, 0.5]);
TextStyle panelTextStyle = TextStyle(color: onPanelFgColor, fontSize: 20);
TextStyle bgTextStyle = TextStyle(color: onBgFgColor, fontSize: 20);
BoxDecoration buttonDecoration = BoxDecoration(
  gradient: panelGradient,
  borderRadius: BorderRadius.all(Radius.circular(6)),
);
