import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

const secretKey = 'your_secret_key';

Middleware jwtMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      // Hanya memeriksa token jika ada
      final authHeader = request.headers['Authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7);
        try {
          final jwt = JWT.verify(token, SecretKey(secretKey));
          request = request.change(context: {'user': jwt.payload});
          return handler(request);
        } catch (e) {
          return Response.forbidden('Invalid or expired token');
        }
      }

      // Lanjutkan request jika tidak ada token (rute yang tidak membutuhkan token)
      return handler(request);
    };
  };
}
