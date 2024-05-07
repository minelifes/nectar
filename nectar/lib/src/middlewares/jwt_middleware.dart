import 'package:get_it/get_it.dart';
import 'package:nectar/nectar.dart';

Middleware checkJwtMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authorizationHeader = request.headers['authorization'];

      if (authorizationHeader == null ||
          !authorizationHeader.startsWith('Bearer ')) {
        return Response.forbidden(
            jsonEncode({'error': 'Missing or invalid authorization header.'}));
      }

      final jwt = authorizationHeader.substring('Bearer '.length);
      if (jwt.isEmpty) {
        return Response.unauthorized(jsonEncode({'error': 'Empty token.'}));
      }

      if (!GetIt.I.get<Nectar>().isJwtConfigured) {
        return Response.forbidden(jsonEncode({'error': 'JWT not configured!'}));
      }

      final jwtSec = GetIt.I.get<JwtSecurity>();
      final payload = jwtSec.getPayload(jwt);
      if (payload == null) {
        return Response.forbidden(jsonEncode({'error': 'Invalid token.'}));
      }

      final userDetails = await jwtSec.userDetailsFromPayload(payload);
      if (userDetails == null) {
        return Response.forbidden(jsonEncode({'error': 'Invalid token.'}));
      }

      if (userDetails.isBlocked) {
        return Response.forbidden(jsonEncode({'error': 'User is blocked.'}));
      }

      final newReq = request.change(context: {
        ...request.context,
        MiddlewareKeys.token: payload,
        MiddlewareKeys.userDetails: userDetails,
      });

      return innerHandler(newReq);
    };
  };
}
