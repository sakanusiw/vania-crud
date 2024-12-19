import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'db.dart'; // Koneksi database dari database.dart

Router orderItemsRoutes() {
  final router = Router();

  // GET semua orderitems
  router.get('/', (Request req) async {
    final conn = await connectDb();
    final results = await conn.query('SELECT * FROM orderitems');
    final orderItems = results
        .map((row) => {
              'order_item': row['order_item'],
              'order_num': row['order_num'],
              'prod_id': row['prod_id'],
              'quantity': row['quantity'],
              'size': row['size']
            })
        .toList();
    await conn.close();
    return Response.ok(jsonEncode(orderItems),
        headers: {'Content-Type': 'application/json'});
  });

  // GET orderitems berdasarkan order_item
  router.get('/<id>', (Request req, String id) async {
    final conn = await connectDb();
    final results =
        await conn.query('SELECT * FROM orderitems WHERE order_item = ?', [id]);
    if (results.isEmpty) {
      await conn.close();
      return Response.notFound(jsonEncode({'error': 'Order item not found'}),
          headers: {'Content-Type': 'application/json'});
    }
    final orderItem = results
        .map((row) => {
              'order_item': row['order_item'],
              'order_num': row['order_num'],
              'prod_id': row['prod_id'],
              'quantity': row['quantity'],
              'size': row['size']
            })
        .first;
    await conn.close();
    return Response.ok(jsonEncode(orderItem),
        headers: {'Content-Type': 'application/json'});
  });

  // POST order item baru
  router.post('/', (Request req) async {
    final payload = jsonDecode(await req.readAsString());
    final conn = await connectDb();
    await conn.query(
        'INSERT INTO orderitems (order_item, order_num, prod_id, quantity, size) VALUES (?, ?, ?, ?, ?)',
        [
          payload['order_item'],
          payload['order_num'],
          payload['prod_id'],
          payload['quantity'],
          payload['size']
        ]);
    await conn.close();
    return Response.ok(jsonEncode({'message': 'Order item added successfully'}),
        headers: {'Content-Type': 'application/json'});
  });

  // PUT (update) order item
  router.put('/<id>', (Request req, String id) async {
    final payload = jsonDecode(await req.readAsString());
    final conn = await connectDb();
    final result = await conn.query(
        'UPDATE orderitems SET order_num = ?, prod_id = ?, quantity = ?, size = ? WHERE order_item = ?',
        [
          payload['order_num'],
          payload['prod_id'],
          payload['quantity'],
          payload['size'],
          id
        ]);
    await conn.close();
    if (result.affectedRows == 0) {
      return Response.notFound(jsonEncode({'error': 'Order item not found'}),
          headers: {'Content-Type': 'application/json'});
    }
    return Response.ok(
        jsonEncode({'message': 'Order item updated successfully'}),
        headers: {'Content-Type': 'application/json'});
  });

  // DELETE order item
  router.delete('/<id>', (Request req, String id) async {
    final conn = await connectDb();
    final result =
        await conn.query('DELETE FROM orderitems WHERE order_item = ?', [id]);
    await conn.close();
    if (result.affectedRows == 0) {
      return Response.notFound(jsonEncode({'error': 'Order item not found'}),
          headers: {'Content-Type': 'application/json'});
    }
    return Response.ok(
        jsonEncode({'message': 'Order item deleted successfully'}),
        headers: {'Content-Type': 'application/json'});
  });

  return router;
}
