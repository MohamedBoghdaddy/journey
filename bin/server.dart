import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:masr_spaces_app/handlers/auth_handler.dart';
import 'package:masr_spaces_app/handlers/group_handler.dart';
import 'package:masr_spaces_app/handlers/post_handler.dart';
import 'package:masr_spaces_app/handlers/report_handler.dart';
import 'package:masr_spaces_app/handlers/space_handler.dart';

Future<void> main(List<String> args) async {
  final ip = InternetAddress.anyIPv4;
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  final router = Router()
    ..mount('/auth', AuthHandler().router)
    ..mount('/spaces', SpaceHandler().router)
    ..mount('/groups', GroupHandler().router)
    ..mount('/posts', PostHandler().router)
    ..mount('/reports', ReportHandler().router);

  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(router);

  final server = await io.serve(handler, ip, port);
  print('Server listening on http://${server.address.host}:${server.port}');
}
