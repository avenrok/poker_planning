import 'package:server/api/rooms_api.dart' as server;

import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import '../lib/db/postgres.dart';
import '../lib/api/rooms_api.dart';

void main() async {
  await PostgresDb.connect();

  final router = Router();

  router.mount('/rooms/', RoomsApi().router.call);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('Server started: http://${server.address.host}:${server.port}');
}