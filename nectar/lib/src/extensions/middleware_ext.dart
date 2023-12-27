import 'package:shelf_plus/shelf_plus.dart';

extension MiddlewareExtension on Middleware {
  Middleware operator +(Middleware middleware) =>
      Pipeline().addMiddleware(this).addMiddleware(middleware).middleware;

  dynamic operator >>(dynamic data) {
    return Pipeline()
        .addMiddleware(this)
        .addHandler((request) async => await resolveResponse(request, data));
  }
}
