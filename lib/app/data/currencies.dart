import "package:decimal/decimal.dart";
import 'package:get/get.dart';

import '../db_connections/mariadb_connector.dart';

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

  CurrencyData() {
    names = <String>[];
    values = <Decimal>[];
    fetchData();
  }

  Future<void> fetchData() async {
    var results = await mariaDBConnector.getCurrencyList();
    for (var row in results) {
      names.add(row[1]);
      values.add(Decimal.parse(row[2].toString()));
    }
    ready = true;
  }
}
