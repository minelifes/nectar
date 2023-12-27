import 'dart:convert';

import 'package:nectar/nectar.dart';
import 'package:shelf_plus/shelf_plus.dart';

Middleware hasRoleMiddleware(List<String> role) {
  return (Handler innerHandler) {
    return (Request request) async {
      if (!request.context.keys.contains(MiddlewareKeys.userDetails)) {
        return Response.unauthorized(
            jsonEncode({'error': 'User not authorized.'}));
      }
      final user = request.context[MiddlewareKeys.userDetails]! as UserDetails;
      if (!user.allowedWithRole(role)) {
        return Response.forbidden(jsonEncode({'error': 'Access denied.'}));
      }
      return innerHandler(request);
    };
  };
}
