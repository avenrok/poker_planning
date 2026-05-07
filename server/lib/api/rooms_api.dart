import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

class RoomsApi {
  final router = Router();

  RoomsApi() {
    router.get('/', _getRooms);
    router.post('/', _createRoom);
  }

  Future<Response> _getRooms(Request request) async {
    return Response.ok(
      jsonEncode([]),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _createRoom(Request request) async {
    final body = jsonDecode(await request.readAsString());

    final room = {
      'id': const Uuid().v4(),
      'name': body['name'],
    };

    return Response.ok(
      jsonEncode(room),
      headers: {'Content-Type': 'application/json'},
    );
  }
}