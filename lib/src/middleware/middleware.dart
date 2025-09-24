import 'dart:io';

import 'package:volt/src/core/request.dart';
import 'package:volt/src/core/response.dart';

typedef NextFunction = void Function();

typedef RequestHandler = Future<dynamic> Function(
    Request req, Response res, NextFunction next);

Future<Response> voltSigntureMiddleware(
    Request req, Response res, NextFunction next) async {
  res.headers.set(HttpHeaders.userAgentHeader, 'Volt');
  res.headers.set('x-power-by', 'Dart package:volt');

  return res;
}

RequestHandler logRequest() => (req, res, next) async {};
