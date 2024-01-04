import 'package:nectar/nectar.dart';

Middleware setHeadersMiddleware(Map<String, String> headers) =>
    (Handler innerHandler) => (Request request) async =>
        (await innerHandler(request)).change(headers: {
          ...request.headers,
          "x-powered-by": "Nectar Engine",
          ...headers
        });
