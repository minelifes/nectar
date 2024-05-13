import 'package:nectar/nectar.dart';

Middleware hasPrivilegeMiddleware(List<String> privilege) {
  return (Handler innerHandler) {
    return (Request request) async {
      if (!request.context.keys.contains(MiddlewareKeys.userDetails)) {
        return Response.forbidden(
            jsonEncode({'error': 'User not authorized.'}));
      }
      final user = request.context[MiddlewareKeys.userDetails]! as UserDetails;
      if (!user.allowedWithPrivilege(privilege)) {
        return Response.forbidden(jsonEncode({'error': 'Access denied.'}));
      }
      return innerHandler(request);
    };
  };
}
