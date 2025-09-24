import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:volt/src/middleware/middleware.dart';

RequestHandler jsonMiddleware() => (req, res, next) async {
      if (req.headers.contentType?.mimeType != ContentType.json.mimeType) {
        return next();
      }

      final body = req.getBody();

      if (body is String) {
        req.setBody(jsonDecode(body));
      }

      if (body is Uint8List) {
        req.setBody(
          jsonDecode(
            String.fromCharCodes(body),
          ),
        );
      }
      return next();
    };
