import 'package:nectar/nectar.dart';

Middleware contextProviderMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final header = request.headers["ProjectID"];

      return await (Scope()
            ..value(
                Nectar.context,
                NectarContext(
                  tenant: header,
                  user: request.context[MiddlewareKeys.userDetails]
                      as UserDetails?,
                )))
          .run(() async => innerHandler(request));
    };
  };
}
