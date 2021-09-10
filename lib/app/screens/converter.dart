import 'dart:convert';
import 'package:get/get.dart';
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
  RxInt fromVal = 1.obs;
  RxInt toVal = 1.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Currency Converter"),
        backgroundColor: Color(0xFFF33845),
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
                  Expanded(
                      child: Column(
                    children: [
                      Text("Enter Amount:"),
                      TextField(
                        controller: TextEditingController(text: "Hello world!"),
                        decoration: InputDecoration(),
                      ),
                    ],
                  )),
                  Expanded(
                    child: Column(
                      children: [
                        Text("From:"),
                        Obx(() => DropdownButton(
                              onChanged: (int? newValue) {
                                fromVal.value = newValue ?? 0;
                              },
                              value: fromVal.value,
                              items: [
                                DropdownMenuItem(child: Text("1"), value: 1),
                                DropdownMenuItem(child: Text("2"), value: 2),
                                DropdownMenuItem(child: Text("3"), value: 3),
                                DropdownMenuItem(child: Text("4"), value: 4),
                              ],
                            )),
                      ],
                    ),
                  ),
                  Icon(Icons.swap_horiz),
                  Expanded(
                    child: Column(
                      children: [
                        Text("To:"),
                        Obx(() => DropdownButton(
                              onChanged: (int? newValue) {
                                toVal.value = newValue ?? 0;
                              },
                              value: toVal.value,
                              items: [
                                DropdownMenuItem(child: Text("1"), value: 1),
                                DropdownMenuItem(child: Text("2"), value: 2),
                                DropdownMenuItem(child: Text("3"), value: 3),
                                DropdownMenuItem(child: Text("4"), value: 4),
                              ],
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FittedBox(
                child: Row(
              children: [
                ElevatedButton(
                  child: Text("Convert"),
                  onPressed: () {},
                ),
                ElevatedButton(
                  child: Text("Clear"),
                  onPressed: () {},
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
