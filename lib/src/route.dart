import 'package:volt/src/middleware/middleware.dart';

// ignore: constant_identifier_names
const _PLACEHOLDER_PREFIX = ':';

class Route {
  final String path;
  final String method;
  final List<RequestHandler> middlewares;
  final RequestHandler handler;

  Route({
    required this.path,
    required this.method,
    required this.middlewares,
    required this.handler,
  });

  Map<String, String> extractParams(Uri url) {
    final result = <String, String>{};

    final routeSegments = Uri.parse(path).pathSegments;
    final urlSegments = url.pathSegments;

    for (int i = 0; i < routeSegments.length; i++) {
      final routeSegment = routeSegments[i];
      final urlSegment = urlSegments[i];

      if (isPlaceholderSegment(routeSegment)) {
        result[_removePlaceholderPrefix(routeSegment)] = urlSegment;
      }
    }

    return result;
  }

  bool isMatch(Uri url, String method) {
    if (method != this.method) return false;

    final routeSegments = Uri.parse(path).pathSegments;
    final urlSegments = url.pathSegments;

    if (routeSegments.length != urlSegments.length) return false;

    for (int i = 0; i < routeSegments.length; i++) {
      final routeSegment = routeSegments[i];
      final urlSegment = urlSegments[i];

      if (!isPlaceholderSegment(routeSegment) && routeSegment != urlSegment) {
        return false;
      }

      if (isPlaceholderSegment(routeSegment) && urlSegment.trim() == '') {
        return false;
      }
    }

    return true;
  }
}

bool isPlaceholderSegment(String segment) =>
    segment.trim().startsWith(_PLACEHOLDER_PREFIX);

String _removePlaceholderPrefix(String placeholder) {
  if (placeholder.length == 1) {
    return '';
  }

  return placeholder.substring(1);
}
