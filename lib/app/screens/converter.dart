import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

class ConverterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ConverterScreenState();
  }
}

// TODO: Implement

class ConverterScreenState extends State<ConverterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Currency Converter"),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Text("Placeholder"),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Text("Currency Converter"),
              Text("Converted Currency"),
              Text(""),
              Container(
                margin: EdgeInsets.fromLTRB(6, 4, 6, 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    gradient: LinearGradient(
                        colors: [Color(0xFFec2075), Color(0xFFf33944)],
                        stops: [0.0, 0.5])),
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Text("Placeholder!"),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
