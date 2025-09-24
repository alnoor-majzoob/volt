import 'dart:io';
import 'dart:typed_data';

import 'package:volt/src/core/request.dart';
import 'package:volt/src/core/response.dart';
import 'package:volt/src/error.dart';
import 'package:volt/src/middleware/json.dart';
import 'package:volt/src/middleware/middleware.dart';
import 'package:volt/src/pair.dart';
import 'package:volt/src/route.dart';

import 'package:volt/src/router.dart';

class Volt extends Router {
  final SecurityContext? securityContext;
  late final HttpServer _server;
  ErrorHandler _errorHandler = defaultErrorHandler;
  bool _isRunning = false;

  Volt({
    this.securityContext,
  });

  @override
  void use(dynamic value) {
    if (_isRunning) {
      throw VoltError(
          '"use()" method can\'t be used after calling "listen()" method.');
    }

    if (value is ErrorHandler) {
      _errorHandler = value;
    } else if (value is RequestHandler) {
      useMiddleware(this, value);
    } else if (value is Router) {
      super.use(value);
    } else {
      throw VoltError(
          'Only value of following typies are accepted (ErrorHandler, RequestHandler, Router).');
    }
  }

  Pair<Route?, Pair<List<RequestHandler>, List<RequestHandler>>>
      _findRouteWithMiddlewares(Uri url, String method) {
    final innerMiddlewares = <RequestHandler>[];
    final outerMiddlewares = <RequestHandler>[];

    Route? targetRoute;

    for (final elem in this) {
      if (elem is RequestHandler && targetRoute != null) {
        outerMiddlewares.add(elem);
      }

      if (elem is RequestHandler && targetRoute == null) {
        innerMiddlewares.add(elem);
      }

      if (elem is Router && targetRoute == null) {
        targetRoute = findRoute(elem, url, method);
      }

      if (elem is Route && targetRoute == null && elem.isMatch(url, method)) {
        targetRoute = elem;
      }
    }

    return targetRoute == null
        ? Pair(
            first: null,
            second: Pair(first: [], second: []),
          )
        : Pair(
            first: targetRoute,
            second: Pair(first: innerMiddlewares, second: outerMiddlewares),
          );
  }

  void _entryPoint(HttpRequest request) async {
    final body = request.contentLength == -1
        ? ''
        : await request.reduce((a, b) => Uint8List.fromList([...a, ...b]));
    final req = Request(request, {
      'body': body,
    });
    final res = Response(req.response);

    try {
      final result =
          _findRouteWithMiddlewares(request.requestedUri, request.method);

      if (result.first == null) {
        res.statusCode = 404;

        return _endResponse(
          await voltSigntureMiddleware(
              req,
              res
                ..plain(
                  'Can\'t ${request.method} ${request.requestedUri.path}',
                ),
              () => 0),
        );
      }

      final requestParams = result.first!.extractParams(request.requestedUri);
      req.extra['params'] = requestParams;

      final requestPipeline = [
        ...result.second.first,
        result.first!.handler,
      ];

      final responsePipeline = result.second.second;

      final innerMiddlewareResponse =
          await _proccessRequest(requestPipeline, req, res);
      final outerMiddlewareResponse = await _proccessResponse(
          responsePipeline, req, innerMiddlewareResponse);

      return _endResponse(outerMiddlewareResponse);
    } catch (e, s) {
      final errorResponse = await _errorHandler(e, s, req, res);
      return _endResponse(
          await voltSigntureMiddleware(req, errorResponse, () => 0));
    }
  }

  Future<Response> _proccessRequest(
      List<RequestHandler> pipeline, Request req, Response res) async {
    for (var pipe in pipeline) {
      final result = await pipe.call(req, res, () => 0);
      if (result is Response) {
        return result;
      }
    }

    return res;
  }

  Future<Response> _proccessResponse(
      List<RequestHandler> pipeline, Request req, Response res) async {
    for (var pipe in pipeline) {
      await pipe.call(req, res, () => 0);
    }

    return res;
  }

  void _endResponse(Response res) async {
    final body = res.extra['body'];

    if (body is Iterable) {
      res.writeAll(body);
    } else {
      res.write(body);
    }

    res.close();
  }

  static RequestHandler json() => jsonMiddleware();
  // static RequestHandler text() => textMiddleware();
  // static RequestHandler binary() => binaryMiddleware();
  // static RequestHandler urlencoded() => urlEncodedMiddleware();
  // static RequestHandler formdata([int maxSize = 5 * 1024 * 1024]) =>
  //     formDataMiddleware(maxSize);

  // static RequestHandler static(String path, [useHeaderContentType = true]) =>
  //     staticMiddleware(path, useHeaderContentType: useHeaderContentType);

  Future<void> listen(int port, {void Function()? onConnected}) async {
    if (securityContext != null) {
      _server = await HttpServer.bindSecure(
          InternetAddress.anyIPv4, port, securityContext!);
    } else {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    }

    _server.listen(_entryPoint);

    use(voltSigntureMiddleware);
    onConnected?.call();
    _isRunning = true;
  }
}
