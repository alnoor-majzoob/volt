import 'package:volt/src/core/request.dart';
import 'package:volt/src/core/response.dart';

typedef ErrorHandler = Future<Response> Function(
    Object error, StackTrace stackTrace, Request req, Response res);

class VoltError implements Exception {
  final String msg;

  VoltError(this.msg);

  @override
  String toString() => '${runtimeType.toString()}: $msg';
}

Future<Response> defaultErrorHandler(
    Object error, StackTrace stackTrace, Request req, Response res) async {
  res.statusCode = 500;
  return res..plain("${error.toString()}: ${stackTrace.toString()}");
}
