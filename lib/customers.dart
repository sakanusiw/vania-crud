import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'db.dart';

Router customersRoutes() {
  final router = Router();

  // GET semua customers
  router.get('/', (Request req) async {
    final conn = await connectDb();
    final results = await conn.query('SELECT * FROM customers');
    final customers = results
        .map((row) => {
              'cust_id': row['cust_id'],
              'cust_name': row['cust_name'],
              'cust_address': row['cust_address'],
              'cust_city': row['cust_city'],
              'cust_state': row['cust_state'],
              'cust_zip': row['cust_zip'],
              'cust_country': row['cust_country'],
              'cust_telp': row['cust_telp']
            })
        .toList();
    await conn.close();
    return Response.ok(jsonEncode(customers),
        headers: {'Content-Type': 'application/json'});
  });

  // GET customer berdasarkan ID
  router.get('/<id>', (Request req, String id) async {
    final conn = await connectDb();
    final results =
        await conn.query('SELECT * FROM customers WHERE cust_id = ?', [id]);
    if (results.isEmpty) {
      return Response.notFound(jsonEncode({'error': 'Customer not found'}),
          headers: {'Content-Type': 'application/json'});
    }
    final customer = results
        .map((row) => {
              'cust_id': row['cust_id'],
              'cust_name': row['cust_name'],
              'cust_address': row['cust_address'],
              'cust_city': row['cust_city'],
              'cust_state': row['cust_state'],
              'cust_zip': row['cust_zip'],
              'cust_country': row['cust_country'],
              'cust_telp': row['cust_telp']
            })
        .first;
    await conn.close();
    return Response.ok(jsonEncode(customer),
        headers: {'Content-Type': 'application/json'});
  });

  // POST customer baru
  router.post('/', (Request req) async {
    final payload = jsonDecode(await req.readAsString());
    final conn = await connectDb();
    await conn.query(
        'INSERT INTO customers (cust_id, cust_name, cust_address, cust_city, cust_state, cust_zip, cust_country, cust_telp) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          payload['cust_id'],
          payload['cust_name'],
          payload['cust_address'],
          payload['cust_city'],
          payload['cust_state'],
          payload['cust_zip'],
          payload['cust_country'],
          payload['cust_telp']
        ]);
    await conn.close();
    return Response.ok(jsonEncode({'message': 'Customer added successfully'}),
        headers: {'Content-Type': 'application/json'});
  });

  // PUT (update) customer
  router.put('/<id>', (Request req, String id) async {
    final payload = jsonDecode(await req.readAsString());
    final conn = await connectDb();
    final result = await conn.query(
        'UPDATE customers SET cust_name = ?, cust_address = ?, cust_city = ?, cust_state = ?, cust_zip = ?, cust_country = ?, cust_telp = ? WHERE cust_id = ?',
        [
          payload['cust_name'],
          payload['cust_address'],
          payload['cust_city'],
          payload['cust_state'],
          payload['cust_zip'],
          payload['cust_country'],
          payload['cust_telp'],
          id
        ]);
    await conn.close();
    if (result.affectedRows == 0) {
      return Response.notFound(jsonEncode({'error': 'Customer not found'}),
          headers: {'Content-Type': 'application/json'});
    }
    return Response.ok(jsonEncode({'message': 'Customer updated successfully'}),
        headers: {'Content-Type': 'application/json'});
  });

  // DELETE customer
  router.delete('/<id>', (Request req, String id) async {
    final conn = await connectDb();
    final result =
        await conn.query('DELETE FROM customers WHERE cust_id = ?', [id]);
    await conn.close();
    if (result.affectedRows == 0) {
      return Response.notFound(jsonEncode({'error': 'Customer not found'}),
          headers: {'Content-Type': 'application/json'});
    }
    return Response.ok(jsonEncode({'message': 'Customer deleted successfully'}),
        headers: {'Content-Type': 'application/json'});
  });

  return router;
}
