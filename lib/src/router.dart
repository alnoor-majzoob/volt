import 'package:volt/src/error.dart';
import 'package:volt/src/http_methods.dart';
import 'package:volt/src/middleware/middleware.dart';
import 'package:volt/src/route.dart';
import 'package:volt/src/core/request.dart';
import 'package:volt/src/core/response.dart';

typedef Handler = Future<Response> Function(Request req, Response res);

void useMiddleware(Router router, RequestHandler middleware) =>
    router._routes.add(middleware);

class Router extends Iterable<dynamic> {
  final List<dynamic> _routes = [];
  final String? name;

  Router([
    this.name,
  ]);

  String _fullPath(String path) {
    if (name != null) {
      final correctPath = (path.startsWith('/') ? path : '/$path');
      return name! + correctPath;
    }

    return path;
  }

  void get(
    String path,
    Handler handler, {
    List<RequestHandler> middlewares = const [],
  }) {
    _routes.add(
      Route(
        path: _fullPath(path),
        method: HttpMethods.get,
        middlewares: middlewares,
        handler: (req, res, next) => handler(req, res),
      ),
    );
  }

  void post(
    String path,
    Handler handler, {
    List<RequestHandler> middlewares = const [],
  }) {
    _routes.add(
      Route(
        path: _fullPath(path),
        method: HttpMethods.post,
        middlewares: middlewares,
        handler: (req, res, next) => handler(req, res),
      ),
    );
  }

  void put(
    String path,
    Handler handler, {
    List<RequestHandler> middlewares = const [],
  }) {
    _routes.add(
      Route(
        path: _fullPath(path),
        method: HttpMethods.put,
        middlewares: middlewares,
        handler: (req, res, next) => handler(req, res),
      ),
    );
  }

  void delete(
    String path,
    Handler handler, {
    List<RequestHandler> middlewares = const [],
  }) {
    _routes.add(
      Route(
        path: _fullPath(path),
        method: HttpMethods.delete,
        middlewares: middlewares,
        handler: (req, res, next) => handler(req, res),
      ),
    );
  }

  void patch(
    String path,
    Handler handler, {
    List<RequestHandler> middlewares = const [],
  }) {
    _routes.add(
      Route(
        path: _fullPath(path),
        method: HttpMethods.patch,
        middlewares: middlewares,
        handler: (req, res, next) => handler(req, res),
      ),
    );
  }

  void head(
    String path,
    Handler handler, {
    List<RequestHandler> middlewares = const [],
  }) {
    _routes.add(
      Route(
        path: _fullPath(path),
        method: HttpMethods.head,
        middlewares: middlewares,
        handler: (req, res, next) => handler(req, res),
      ),
    );
  }

  void use(dynamic value) {
    if (value is! Router) {
      throw VoltError('Router can\' only use other router.');
    }

    if (value.name != null) {
      _routes.add(value);
    } else {
      for (final elem in value._routes) {
        if (elem is Route) {
          _routes.add(elem);
        } else {
          use(elem);
        }
      }
    }
  }

  Route? findRoute(Router router, Uri url, String method,
      [int segmentIndex = 0]) {
    for (final elem in router._routes) {
      if (elem is Route) {
        if (elem.isMatch(url, method)) {
          return elem;
        }
      } else if (elem is Router) {
        if (url.pathSegments[segmentIndex] == elem.name) {
          return findRoute(elem, url, method, segmentIndex + 1);
        }
      }
    }

    return null;
  }

  @override
  Iterator get iterator => _routes.iterator;
}
