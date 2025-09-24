import 'dart:typed_data';

import 'package:volt/src/router.dart';
import 'package:volt/src/volt_impl.dart';

void main() async {
  final app = Volt();

  final router = Router('user');

  router.get('/:id', (req, res) async {
    print(req.getBody());
    print(req.params);
    print(req.queries);

    return res
      ..statusCode = 201
      ..binary(Uint8List.fromList(List.generate(100, (i) => i)));
  });

  app.use(Volt.json());

  app.use(router);

  app.listen(8080);
}
