import "package:decimal/decimal.dart";
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';

import '../db_connections/mariadb_connector.dart';
import '../db_connections/sqlite_connector.dart';

// final Map<String, Decimal> currencyList = <String, Decimal>{
//   "INR": Decimal.parse('1'),
//   "USD": Decimal.parse('75'),
//   "EUR": Decimal.parse('85'),
//   "SAR": Decimal.parse('20'),
//   "POUND": Decimal.parse('5'),
//   "DEM": Decimal.parse('43'),
// };.

CurrencyData? sharedCurrencyData;

class CurrencyData extends GetxController {
  // Load data from database and store it.
  late List<String> names;
  late List<Decimal> values;
  bool ready = false;
  late Future fetchingData;

  CurrencyData() {
    names = <String>[];
    values = <Decimal>[];
    fetchingData = fetchData();
  }

  Future<void> fetchData() async {
    await fetchDataSqlite();
    ready = true;
  }

  Future<void> fetchDataSqlite() async {
    Future<void> extract() async {
      var data = await sqliteConnector.getCurrencyDataTrimmed();
      for (var row in data) {
        names.add(row["name"] as String);
        values.add(Decimal.parse(row["value"] as String));
      }
    }

    if (await sqliteConnector.checkDB()) {
      await extract();
    } else {
      await sqliteConnector.createCurrencyTable();
      await sqliteConnector.populateDefaultData();
      await extract();
    }
  }

  Future<void> fetchDataMariaDB() async {
    var results = await mariaDBConnector.getCurrencyList();
    for (var row in results) {
      names.add(row[1]);
      values.add(Decimal.parse(row[2].toString()));
    }
  }

  Future<void> updateFromInternet() async {
    HttpClient client = HttpClient();
    var response = await client
        .getUrl(Uri.parse(
            "https://openexchangerates.org/api/latest.json?app_id=02213fccad46472d8934f3fb57519a6d"))
        .then((HttpClientRequest request) {
      return request.close();
    });

    String output = await response.transform(utf8.decoder).join();
    Map<String, Object?> jsonData = json.decode(output);
    // print(jsonData["timestamp"]);
    // print(jsonData["base"]);
    // print(jsonData["rates"]);
    Map<String, double> rates =
        (jsonData["rates"] as Map<String, Object?>).map((key, value) {
      if (value is int)
        return MapEntry(key, value.toDouble());
      else
        return MapEntry(key, value as double);
    });
    Map<String, Decimal> ratesDecimal = rates.map((String key, double value) {
      return MapEntry(key, Decimal.parse(value.toString()));
    });
    ratesDecimal[jsonData["base"] as String] = Decimal.one;

    Future op = updateSqlite(ratesDecimal);
    names.clear();
    values.clear();
    ratesDecimal.forEach((key, value) {
      names.add(key);
      values.add(value);
    });
    await op;
  }

  Future<void> updateSqlite(Map<String, Decimal> data) async {
    await sqliteConnector.initialized;

    // Get current Sqlite data
    List<Map<String, Object?>> sqliteData =
        await sqliteConnector.getCurrencyDataFull();

    var batch = sqliteConnector.db!.batch();

    // iterate through existing data. Update if match is found, delete
    // if match is not.
    // Mark all items as processed
    List<String> processed = [];
    for (var row in sqliteData) {
      if (data[row["name"]] != null) {
        batch.update("currency_table", {"value": data[row["name"]].toString()},
            where: "id=?", whereArgs: [row["id"]]);
      } else {
        batch.delete("currency_table", where: "id=?", whereArgs: [row["id"]]);
      }
      processed.add(row["name"] as String);
    }

    // For the remaining items that exist in data but not the sqlite database,
    // insert a new row.
    data.forEach((key, value) {
      if (processed.contains(key)) return;
      var newRow = {"name": key, "value": value.toString()};
      batch.insert("currency_table", newRow);
    });
    batch.commit();
  }
}
