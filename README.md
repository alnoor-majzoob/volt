# volt

A lightweight, Express.js-inspired HTTP server framework for Dart built
on top of `dart:io` `HttpServer`.

**Highlights**

-   Fast, tree-based routing with support for dynamic path parameters
    (`/users/:id`).
-   Global and local middleware chaining (router-level and route-level).
-   Built-in body parsers: JSON, `application/x-www-form-urlencoded`,
    `text/plain`, and multipart file uploads (with disk storage helper).
-   Static file serving middleware with optional directory listing and
    caching support.
-   Simple, pluggable template-engine API with a default
    `volt_html_engine` implementation.
-   Small, explicit API that mirrors common server patterns familiar
    from Express.

------------------------------------------------------------------------

## Installation

add `volt` as a dependency in your
`pubspec.yaml`:

``` yaml
dependencies:
  volt:
    git:
      url: https://github.com/alnoor-majzoob/volt.git
```

------------------------------------------------------------------------

## Quick start

A minimal example that starts a server, registers a couple routes and
serves static files:

``` dart
import 'dart:io';
import 'package:volt/volt.dart';

Future<void> main() async {
  final app = Volt();

  // Global middlewares
  app.use(BodyParser.json());
  app.use(BodyParser.formurlencoded());
  app.use(BodyParser.plain());

  // Serve `./public` directory at the root of the URL (prefix = '')
  app.use(static('public', prefix: '', listDir: true));

  // Basic routes
  app.get('/', (req, res) async {
    await res.plain('Hello from Volt!');
  });

  app.get('/users/:id', (req, res) async {
    final id = req.params['id'];
    await res.json({
      'id': id,
      'query': req.queryParams,
    });
  });

  // Start listening on port 8080
  await app.listen(8080);
}
```

> Note: response helper methods such as `res.json()`, `res.plain()` and
> `res.html()` write the body and close the response stream for you, so
> you usually don't need to call `res.close()` after them.

------------------------------------------------------------------------

## Routing & routers

`Volt` exposes top-level routing methods that forward to an internal
`Router`:

-   `get`, `post`, `put`, `delete`, `head`, `patch` --- each accepts a
    path, a `RequestHandler`, and an optional list of route-local
    middlewares.

You can create a `Router`, attach middlewares to it and then mount it
under a top-level path using `useRouter(name, router)`. Mounted routers
live under the top-level path segment equal to the `name` you provide.

Example --- creating & mounting a sub-router:

``` dart
final api = Router();

// router-level middleware
api.use((req, res, next) async {
  final auth = req.headers.value(HttpHeaders.authorizationHeader);
  if (auth == 'secret-token') {
    await next();
    return;
  }

  res.statusCode = HttpStatus.unauthorized;
  await res.plain('Unauthorized');
});

api.get('/info', (req, res) async {
  await res.json({'ok': true});
});

// Mount the router under `/api` (requests to `/api/info`)
app.useRouter('api', api);
```

------------------------------------------------------------------------

## Middlewares

Middlewares follow the signature:

``` dart
typedef Middleware = Future<void> Function(Request req, Response res, NextFunction next);
```

### Built-in body parsers

``` dart
app.use(BodyParser.json());
app.use(BodyParser.formurlencoded());
app.use(BodyParser.plain());
```

### Multipart (file upload)

The multipart parser returns a `MulitpartParser` (see API) that provides
helpers such as `.disk(Directory)` to save files to disk.

``` dart
import 'dart:io';

app.post(
  '/upload',
  (req, res) async {
    final body = req.body; // after the multipart middleware runs

    if (body is MultiPartBody) {
      // fields: Map<String,String>
      // files: Map<String,MultipartFile>
      await res.json({
        'fields': body.fields,
        'files': body.files.keys.toList(),
      });
      return;
    }

    await res.plain('No multipart body parsed', statusCode: HttpStatus.badRequest);
  },
  middlewares: [
    BodyParser.multipart(maxUploadSize: 10 * 1024 * 1024)
        .disk(Directory('uploads')),
  ],
);
```

### Static files

Serve a directory (with optional directory listing and compression):

``` dart
// Serve ./public under '/'
app.use(static('public', prefix: '', listDir: true, enableCompression: true));
```

------------------------------------------------------------------------

## Request & Response (quick reference)

### `Request` (important members)

-   `HttpHeaders headers` --- raw request headers (Dart `HttpHeaders`).
-   `Uri requestedUri` --- the request URI.
-   `String method` --- HTTP method.
-   `Map<String, String> queryParams` --- parsed query parameters
    (single value).
-   `Map<String, List<String>> queryParamsAll` --- all query parameters
    (multi-value).
-   `Map<String, String> params` --- path parameters extracted from
    dynamic routes (`/users/:id`).
-   `Stream<Uint8List> bodyStream` --- raw body stream
    (single-subscription).
-   `Object? body` --- body set by parsers (use `req.setBody(...)`
    internally).

### `Response` (important helpers)

-   `Future<void> json(dynamic data, {int? statusCode})`
-   `Future<void> plain(String text, {int? statusCode})`
-   `Future<void> html(String text, {int? statusCode})`
-   `Future<void> file(String path, {int? startRange, int? endRange})`
-   `Future<void> render(String templete, Map<String, dynamic> data, {String? key, String? templeteEngineName})`
-   `Future<void> renderFile(String path, Map<String, dynamic> data, {String? templeteEngineName})`
-   `void setHeader(String name, Object value, {bool preserveHeaderCase = false})`
-   `set statusCode(int code)` --- set the status code before writing
    the body.
-   `void setExtraValue(String key, Object value)` /
    `Object? getExtraValue(String key)` --- attach extra values to the
    response.

> `render` / `renderFile` use the registered template engines --- the
> default engine name is `volt_html_engine`.

------------------------------------------------------------------------

## Template engine (pluggable)

A template engine must implement `TempleteEngineBase`.

``` dart
class MyEngine implements TempleteEngineBase {
  @override
  Future<String> render(String templete, Map<String, dynamic> data, {String? key}) async {
    // implement your templating logic
    return templete; // trivial example
  }

  @override
  Future<String> renderFile(String path, Map<String, dynamic> data) async {
    final content = File(path).readAsStringSync();
    return render(content, data, key: path);
  }
}

// Register engine
app.useTempleteEngine('my_engine', MyEngine());

// Use it in a response
await res.renderFile('views/home.html', {'title': 'Welcome'}, templeteEngineName: 'my_engine');
```

> Note the API intentionally uses the name `TempleteEngineBase` and the
> default engine key `volt_html_engine`.

------------------------------------------------------------------------

## Error & Not Found handlers

Set a global error handler or a custom not-found handler:

``` dart
app.onError((req, res, error, stack) async {
  // log
  stderr.writeln('Error: $error');
  await res.plain('Internal server error', statusCode: HttpStatus.internalServerError);
});

app.onNotFound((req, res) async {
  res.statusCode = HttpStatus.notFound;
  await res.plain('Custom 404: ${req.requestedUri}');
});
```

------------------------------------------------------------------------


## Contributing

Contributions welcome --- open issues and PRs. Please follow the Dart
package conventions and include tests for new functionality.
