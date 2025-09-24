import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class Response implements HttpResponse {
  final HttpResponse _delegate;
  final Map<String, dynamic> extra = {};

  Response(this._delegate);

  set contentType(ContentType contentType) {
    headers.set(HttpHeaders.contentTypeHeader, contentType.value);
  }

  void plain(String text) {
    contentType = ContentType.text;
    extra['body'] = text;
  }

  void json(dynamic json, {bool toMapConvertor = true}) {
    contentType = ContentType.json;

    if (json is String) {
      extra['body'] = json;
    } else if (json is Map || json is List) {
      final jsonStr = jsonEncode(json);
      extra['body'] = jsonStr;
    } else {
      if (toMapConvertor) {
        final jsonStr = jsonEncode(json.toMap());
        extra['body'] = jsonStr;
      } else {
        final jsonStr = jsonEncode(json.toJson());
        extra['body'] = jsonStr;
      }
    }
  }

  void binary(Uint8List data) {
    contentType = ContentType.binary;
    extra['body'] = data;
  }

  void html(String content) {
    contentType = ContentType.html;
    extra['body'] = content;
  }

  @override
  bool get bufferOutput => _delegate.bufferOutput;

  @override
  int get contentLength => _delegate.contentLength;

  @override
  Duration? get deadline => _delegate.deadline;

  @override
  Encoding get encoding => _delegate.encoding;

  @override
  bool get persistentConnection => _delegate.persistentConnection;

  @override
  String get reasonPhrase => _delegate.reasonPhrase;

  @override
  int get statusCode => _delegate.statusCode;

  @override
  void add(List<int> data) => _delegate.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _delegate.addError(error);

  @override
  Future addStream(Stream<List<int>> stream) => _delegate.addStream(stream);

  @override
  Future close() => _delegate.close();

  @override
  HttpConnectionInfo? get connectionInfo => _delegate.connectionInfo;

  @override
  List<Cookie> get cookies => _delegate.cookies;

  @override
  Future<Socket> detachSocket({bool writeHeaders = true}) =>
      _delegate.detachSocket(writeHeaders: writeHeaders);

  @override
  Future get done => _delegate.done;

  @override
  Future flush() => _delegate.flush();

  @override
  HttpHeaders get headers => _delegate.headers;

  @override
  Future redirect(Uri location, {int status = HttpStatus.movedTemporarily}) =>
      _delegate.redirect(location);

  @override
  void write(Object? object) => _delegate.write(object);

  @override
  void writeAll(Iterable objects, [String separator = ""]) =>
      _delegate.writeAll(objects);

  @override
  void writeCharCode(int charCode) => _delegate.writeCharCode(charCode);

  @override
  void writeln([Object? object = ""]) => _delegate.writeln(object);

  @override
  set bufferOutput(bool bufferOutput) => _delegate.bufferOutput = bufferOutput;

  @override
  set contentLength(int contentLength) =>
      _delegate.contentLength = contentLength;
  @override
  set deadline(Duration? deadline) => _delegate.deadline = deadline;

  @override
  set encoding(Encoding encoding) => _delegate.encoding;

  @override
  set persistentConnection(bool persistentConnection) =>
      _delegate.persistentConnection = persistentConnection;

  @override
  set reasonPhrase(String reasonPhrase) =>
      _delegate.reasonPhrase = reasonPhrase;

  @override
  set statusCode(int statusCode) => _delegate.statusCode = statusCode;
}
