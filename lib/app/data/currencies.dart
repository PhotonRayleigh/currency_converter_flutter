import "package:decimal/decimal.dart";
import 'package:get/get.dart';

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
}
