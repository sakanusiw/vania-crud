import 'package:mysql1/mysql1.dart';

// Fungsi untuk koneksi ke database
Future<MySqlConnection> connectDb() async {
  final settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: 'passwordsaka',
    db: 'vania',
  );
  return await MySqlConnection.connect(settings);
}
