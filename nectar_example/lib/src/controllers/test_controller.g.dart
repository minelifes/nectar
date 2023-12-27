// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_controller.dart';

// **************************************************************************
// NectarRestGenerator
// **************************************************************************

class TestController extends _TestController {
  TestController();

  static void register() {
    Routes.registerRoute((router) {
      final controller = TestController();
      router.get(
        "/api/v1/users/",
        controller._getRolesHandler,
      );

      router.get(
        "/api/v1/users/<id>",
        controller._getByIdHandler,
      );

      router.get(
        "/api/v1/users/int/<id>",
        controller._getIntByIdHandler,
      );

      router.post(
        "/api/v1/users/body",
        controller._testBodyHandler,
        use: Pipeline().addMiddleware(checkJwtMiddleware()).middleware,
      );

      router.get(
        "/api/v1/users/secured",
        controller._securedHandler,
        use: Pipeline().addMiddleware(checkJwtMiddleware()).middleware,
      );

      router.get(
        "/api/v1/users/login",
        controller._loginHandler,
      );
    });
  }

  Future<dynamic> _getRolesHandler(Request request) async {
    return await _returnResponseOrError(() async {
      return await getRoles();
    });
  }

  Future<dynamic> _getByIdHandler(Request request) async {
    return await _returnResponseOrError(() async {
      final defaultValue0 = null;
      String pathValue0 = _convertPathVariableToType(
          'String', request.params["id"], defaultValue0);

      return await getById(pathValue0);
    });
  }

  Future<dynamic> _getIntByIdHandler(Request request) async {
    return await _returnResponseOrError(() async {
      final defaultValue0 = null;
      int pathValue0 = _convertPathVariableToType(
          'int', request.params["id"], defaultValue0);

      return await getIntById(pathValue0);
    });
  }

  Future<dynamic> _testBodyHandler(Request request) async {
    return await _returnResponseOrError(() async {
      final str0 = await request.readAsString();
      final json0 = jsonDecode(str0);
      final body0 = TestRequest.fromJson(json0);

      final userDetails1 =
          request.context[MiddlewareKeys.userDetails]! as UserDetails;

      return await testBody(body0, userDetails1);
    });
  }

  Future<dynamic> _securedHandler(Request request) async {
    return await _returnResponseOrError(() async {
      return await secured();
    });
  }

  Future<dynamic> _loginHandler(Request request) async {
    return await _returnResponseOrError(() async {
      return await login();
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
    } on Exception catch (e) {
      return Response(500, body: jsonEncode({"error": e.toString()}));
    }
  }
}
