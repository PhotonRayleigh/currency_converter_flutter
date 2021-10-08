import 'package:mysql1/mysql1.dart';

final _MariaDBConnector mariaDBConnector = _MariaDBConnector();

class _MariaDBConnector {
  MySqlConnection? connection;

  var settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'Collin',
    password: 'wumIvO7O',
    db: 'currency',
  );

  Future<bool> initializeConnection() async {
    try {
      connection = await MySqlConnection.connect(settings);
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }
}
