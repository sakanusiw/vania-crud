import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:crud/auth.dart';
import 'package:crud/customers.dart';
import 'package:crud/orders.dart';
import 'package:crud/orderitems.dart';
import 'package:crud/products.dart';
import 'package:crud/productnotes.dart';
import 'package:crud/vendors.dart';
import 'package:crud/jwt_middleware.dart';
// Import file lainnya (products.dart, vendors.dart, dll.)

void main() async {
  final app = Router();

  // Tambahkan semua router ke dalam app
  app.mount('/auth', authRoutes());
  app.mount('/customers/', customersRoutes());
  app.mount('/orders/', ordersRoutes());
  app.mount('/products', productsRoutes());
  app.mount('/vendors', vendorsRoutes());
  app.mount('/orderitems', orderItemsRoutes());
  app.mount('/productnotes', productNotesRoutes());
  // Tambahkan mount untuk file lain, seperti products, vendors, dll.

  // Tambahkan JWT Middleware untuk melindungi endpoint
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(jwtMiddleware())
      .addHandler(app);

  // final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);

  final server = await serve(handler, 'localhost', 8080);
  print('Server running on http://localhost:${server.port}');
}
