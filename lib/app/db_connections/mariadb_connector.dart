import 'package:mysql1/mysql1.dart';
import 'package:decimal/decimal.dart';
import 'dart:async';

final _MariaDBConnector mariaDBConnector = _MariaDBConnector();

class _MariaDBConnector {
  late Future waitReady;
  MySqlConnection? connection;

  var settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'Collin',
    password: 'wumIvO7O',
    db: 'currency',
  );

  Future<bool> initializeConnection() async {
    var waiting = Completer();
    waitReady = waiting.future;
    try {
      connection = await MySqlConnection.connect(settings);
      waiting.complete();
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  void saveTable(List<List<Object>> data) {}

  Future<Results> getCurrencyList() async {
    await waitReady;
    return await connection!.query("SELECT * FROM currency_list");
  }

  Future<int> insertRow(String currency, Decimal value) async {
    var result = await connection!.query(
        "INSERT INTO currency_list (name, value) VALUES (?, ?)",
        [currency, value.toString()]);

    return result.insertId!;
  }

  Future deleteRow(int id) async {
    await connection!.query("DELETE FROM currency_list WHERE ID = ?", [id]);
  }

  Future updateRow(int id, String currency, Decimal value) async {
    await connection!.query(
        "UPDATE currency_list SET name=?, value=? WHERE ID = ?",
        [currency, value.toString(), id]);
  }
}

// class SQLCommand {
//   String command = "";
//   List<dynamic> arguments = <dynamic>[];
//   void addUpdateRow(){}
//   void addDeleteRow(){}
//   void addInsertRow(){}
// }
