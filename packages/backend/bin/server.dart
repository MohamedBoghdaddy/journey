import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

import '../lib/handlers/auth_handler.dart';
import '../lib/handlers/post_handler.dart';
import '../lib/handlers/group_handler.dart';
import '../lib/handlers/space_handler.dart';

/// Entry point for the Masr Spaces backend server.
///
/// This sets up a [Router] and mounts route handlers for authentication,
/// posts, groups and spaces. All configuration (Supabase URL, keys, etc.)
/// should be supplied via environment variables or a `.env` file.
Future<void> main(List<String> args) async {
  // Load environment variables from a .env file if present.
  dotenv.load();

  final ip = InternetAddress.anyIPv4;
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  final router = Router()
    ..mount('/auth', AuthHandler().router)
    ..mount('/posts', PostHandler().router)
    ..mount('/groups', GroupHandler().router)
    ..mount('/spaces', SpaceHandler().router);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  final server = await io.serve(handler, ip, port);
  print('Server listening on http://${server.address.host}:${server.port}');
}