import 'package:postgres/postgres.dart';

class PostgresDb {
  static late Connection connection;

  static Future<void> connect() async {
    connection = await Connection.open(
      Endpoint(
        host: 'localhost',
        port: 5432,
        database: 'poker',
        username: 'poker',
        password: 'poker',
      ),
    );

    print('PostgreSQL connected');
  }
}