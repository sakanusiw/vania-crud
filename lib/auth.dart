import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'db.dart'; // Shared koneksi database

const secretKey = 'your_secret_key'; // Kunci rahasia JWT

Router authRoutes() {
  final router = Router();

  // REGISTER - Tambahkan pengguna baru (tidak memerlukan token)
  router.post('/register', (Request req) async {
    // Proses register seperti biasa tanpa perlu pemeriksaan token
    final payload = jsonDecode(await req.readAsString());
    final username = payload['username'];
    final password = payload['password'];
    final email = payload['email'];

    // Pastikan semua parameter ada
    if (username == null || password == null || email == null) {
      return Response.badRequest(
          body: jsonEncode(
              {'error': 'Username, password, and email are required'}),
          headers: {'Content-Type': 'application/json'});
    }

    // Hash password
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    final conn = await connectDb();
    try {
      await conn.query(
          'INSERT INTO users (username, password, email) VALUES (?, ?, ?)',
          [username, hashedPassword, email]);
      await conn.close();
      return Response.ok(
          jsonEncode({'message': 'User registered successfully'}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      await conn.close();
      return Response.internalServerError(
          body: jsonEncode(
              {'error': 'Registration failed', 'details': e.toString()}),
          headers: {'Content-Type': 'application/json'});
    }
  });

  // LOGIN - Verifikasi pengguna dan kirim JWT
  router.post('/login', (Request req) async {
    final payload = jsonDecode(await req.readAsString());
    final username = payload['username'];
    final password = payload['password'];

    if (username == null || password == null) {
      return Response.badRequest(
          body: jsonEncode({'error': 'Username and password are required'}),
          headers: {'Content-Type': 'application/json'});
    }

    final conn = await connectDb();
    final results = await conn.query(
        'SELECT user_id, username, password FROM users WHERE username = ?',
        [username]);

    if (results.isEmpty) {
      await conn.close();
      return Response.unauthorized(
          jsonEncode({'error': 'Invalid username or password'}),
          headers: {'Content-Type': 'application/json'});
    }

    final user = results.first;
    final hashedPassword = user['password'];
    if (!BCrypt.checkpw(password, hashedPassword)) {
      await conn.close();
      return Response.unauthorized(
          jsonEncode({'error': 'Invalid username or password'}),
          headers: {'Content-Type': 'application/json'});
    }

    // Generate JWT
    final jwt = JWT({'id': user['user_id'], 'username': user['username']});
    final token = jwt.sign(SecretKey(secretKey), expiresIn: Duration(hours: 2));

    await conn.close();
    return Response.ok(jsonEncode({'token': token}),
        headers: {'Content-Type': 'application/json'});
  });

  return router;
}
