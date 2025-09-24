import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class Request implements HttpRequest {
  final HttpRequest _delegate;
  final Map<String, dynamic> extra;

  Request(this._delegate, this.extra);

  Map<String, String> get params => extra['params'] ?? {};
  Map<String, String> get queries => requestedUri.queryParameters;

  dynamic getBody() => extra['body'];

  void setBody(dynamic body) {
    extra['body'] = body;
  }

  @override
  Future<bool> any(bool Function(Uint8List element) test) {
    return _delegate.any(test);
  }

  @override
  Stream<Uint8List> asBroadcastStream(
      {void Function(StreamSubscription<Uint8List> subscription)? onListen,
      void Function(StreamSubscription<Uint8List> subscription)? onCancel}) {
    return _delegate.asBroadcastStream(
      onListen: onListen,
      onCancel: onCancel,
    );
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(Uint8List event) convert) {
    return _delegate.asyncExpand(convert);
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(Uint8List event) convert) {
    return _delegate.asyncMap(convert);
  }

  @override
  Stream<R> cast<R>() {
    return _delegate.cast();
  }

  @override
  X509Certificate? get certificate => _delegate.certificate;

  @override
  HttpConnectionInfo? get connectionInfo => _delegate.connectionInfo;

  @override
  Future<bool> contains(Object? needle) {
    return _delegate.contains(needle);
  }

  @override
  int get contentLength => _delegate.contentLength;

  @override
  List<Cookie> get cookies => _delegate.cookies;

  @override
  Stream<Uint8List> distinct(
      [bool Function(Uint8List previous, Uint8List next)? equals]) {
    return _delegate.distinct(equals);
  }

  @override
  Future<E> drain<E>([E? futureValue]) {
    return _delegate.drain(futureValue);
  }

  @override
  Future<Uint8List> elementAt(int index) {
    return _delegate.elementAt(index);
  }

  @override
  Future<bool> every(bool Function(Uint8List element) test) {
    return _delegate.every(test);
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(Uint8List element) convert) {
    return _delegate.expand(convert);
  }

  @override
  Future<Uint8List> get first => _delegate.first;

  @override
  Future<Uint8List> firstWhere(bool Function(Uint8List element) test,
      {Uint8List Function()? orElse}) {
    return _delegate.firstWhere(test);
  }

  @override
  Future<S> fold<S>(
      S initialValue, S Function(S previous, Uint8List element) combine) {
    return _delegate.fold(initialValue, combine);
  }

  @override
  Future<void> forEach(void Function(Uint8List element) action) {
    return _delegate.forEach(action);
  }

  @override
  Stream<Uint8List> handleError(Function onError,
      {bool Function(dynamic error)? test}) {
    return _delegate.handleError(onError);
  }

  @override
  HttpHeaders get headers => _delegate.headers;

  @override
  bool get isBroadcast => _delegate.isBroadcast;

  @override
  Future<bool> get isEmpty => _delegate.isEmpty;

  @override
  Future<String> join([String separator = ""]) {
    return _delegate.join();
  }

  @override
  Future<Uint8List> get last => _delegate.last;

  @override
  Future<Uint8List> lastWhere(bool Function(Uint8List element) test,
      {Uint8List Function()? orElse}) {
    return _delegate.lastWhere(test);
  }

  @override
  Future<int> get length => _delegate.length;

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _delegate.listen(onData);
  }

  @override
  Stream<S> map<S>(S Function(Uint8List event) convert) {
    return _delegate.map(convert);
  }

  @override
  String get method => _delegate.method;

  @override
  bool get persistentConnection => _delegate.persistentConnection;

  @override
  Future pipe(StreamConsumer<Uint8List> streamConsumer) {
    return _delegate.pipe(streamConsumer);
  }

  @override
  String get protocolVersion => _delegate.protocolVersion;

  @override
  Future<Uint8List> reduce(
      Uint8List Function(Uint8List previous, Uint8List element) combine) {
    return _delegate.reduce(combine);
  }

  @override
  Uri get requestedUri => _delegate.requestedUri;

  @override
  HttpResponse get response => _delegate.response;

  @override
  HttpSession get session => _delegate.session;

  @override
  Future<Uint8List> get single => _delegate.single;

  @override
  Future<Uint8List> singleWhere(bool Function(Uint8List element) test,
      {Uint8List Function()? orElse}) {
    return _delegate.singleWhere(test);
  }

  @override
  Stream<Uint8List> skip(int count) {
    return _delegate.skip(count);
  }

  @override
  Stream<Uint8List> skipWhile(bool Function(Uint8List element) test) {
    return _delegate.skipWhile(test);
  }

  @override
  Stream<Uint8List> take(int count) {
    return _delegate.take(count);
  }

  @override
  Stream<Uint8List> takeWhile(bool Function(Uint8List element) test) {
    return _delegate.takeWhile(test);
  }

  @override
  Stream<Uint8List> timeout(Duration timeLimit,
      {void Function(EventSink<Uint8List> sink)? onTimeout}) {
    return _delegate.timeout(timeLimit);
  }

  @override
  Future<List<Uint8List>> toList() {
    return _delegate.toList();
  }

  @override
  Future<Set<Uint8List>> toSet() {
    return _delegate.toSet();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<Uint8List, S> streamTransformer) {
    return _delegate.transform(streamTransformer);
  }

  @override
  Uri get uri => _delegate.uri;

  @override
  Stream<Uint8List> where(bool Function(Uint8List event) test) {
    return _delegate.where(test);
  }
}
