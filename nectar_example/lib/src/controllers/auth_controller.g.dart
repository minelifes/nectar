// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// NectarRestGenerator
// **************************************************************************

class AuthController extends _AuthController {
  AuthController();

  static void register() {
    Routes.registerRoute((router) {
      final controller = AuthController();
      router.post(
        "/api/v1/auth/register",
        controller._registerUserHandler,
        use: setContentType('application/json'),
      );

      router.post(
        "/api/v1/auth/login",
        controller._loginHandler,
        use: setContentType('application/json')
            .addMiddleware(setHeadersMiddleware({
          'TestHeader': 'asdfsfg',
        })),
      );
    });
  }

  Future<dynamic> _registerUserHandler(Request request) async {
    return await _returnResponseOrError(() async {
      final str0 = await request.readAsString();
      final json0 = jsonDecode(str0);
      final body0 = UserCreateRequest.fromJson(json0);

      return await registerUser(body0);
    });
  }

  Future<dynamic> _loginHandler(Request request) async {
    return await _returnResponseOrError(() async {
      final str0 = await request.readAsString();
      final json0 = jsonDecode(str0);
      final body0 = AuthRequest.fromJson(json0);

      return await login(body0);
    });
  }

  dynamic _convertPathVariableToType(
      String type, String? path, String? defaultValue) {
    if (path == null && defaultValue == null) return null;
    switch (type) {
      case 'String':
        return path ?? defaultValue ?? "";
      case 'int':
        return int.tryParse(path ?? defaultValue ?? "");
      case 'double':
        return double.tryParse(path ?? defaultValue ?? "");
      case 'bool':
        return bool.tryParse(path ?? defaultValue ?? "");
    }
  }

  Future<dynamic> _returnResponseOrError(
    Future<dynamic> Function() call,
  ) async {
    try {
      return await call();
    } on RestException catch (e) {
      return Response(e.statusCode, body: jsonEncode({"error": e.toString()}));
    } catch (e) {
      return Response(500, body: jsonEncode({"error": e.toString()}));
    }
  }
}
