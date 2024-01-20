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
        use: Pipeline()
            .addMiddleware(setContentType('application/json'))
            .addMiddleware(setHeadersMiddleware({}))
            .middleware,
      );

      router.get(
        "/api/v1/users/int/<id>",
        controller._getIntByIdHandler,
        use: Pipeline()
            .addMiddleware(setContentType('application/json'))
            .addMiddleware(setHeadersMiddleware({}))
            .middleware,
      );

      router.post(
        "/api/v1/users/body",
        controller._testBodyHandler,
        use: Pipeline()
            .addMiddleware(setContentType('application/json'))
            .addMiddleware(setHeadersMiddleware({}))
            .addMiddleware(checkJwtMiddleware())
            .middleware,
      );

      router.get(
        "/api/v1/users/secured",
        controller._securedHandler,
        use: Pipeline()
            .addMiddleware(setContentType('application/json'))
            .addMiddleware(setHeadersMiddleware({}))
            .addMiddleware(checkJwtMiddleware())
            .addMiddleware(hasRoleMiddleware(['admin']))
            .middleware,
      );

      router.get(
        "/api/v1/users/login",
        controller._loginHandler,
        use: Pipeline()
            .addMiddleware(setContentType('application/json'))
            .addMiddleware(setHeadersMiddleware({}))
            .middleware,
      );

      router.post(
        "/api/v1/users/file",
        controller._fileHandler,
        use: Pipeline()
            .addMiddleware(setContentType('application/json'))
            .addMiddleware(setHeadersMiddleware({}))
            .middleware,
      );

      router.post(
        "/api/v1/users/form",
        controller._formHandler,
        use: Pipeline()
            .addMiddleware(setContentType('application/json'))
            .addMiddleware(setHeadersMiddleware({}))
            .middleware,
      );

      router.get(
        "/api/v1/users/<id>",
        controller._getByIdHandler,
        use: Pipeline()
            .addMiddleware(setContentType('application/json'))
            .addMiddleware(setHeadersMiddleware({}))
            .middleware,
      );
    });
  }

  Future<dynamic> _getRolesHandler(Request request) async {
    return await _returnResponseOrError(() async {
      return await getRoles();
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

  Future<dynamic> _fileHandler(Request request) async {
    if (!request.isMultipart || !request.isMultipartForm) {
      throw RestException.badRequest(message: "request is not form");
    }
    final requestFormData = <String, dynamic>{
      await for (final formData in request.multipartFormData)
        if (formData.filename != null)
          formData.name: MultipartFile(
            name: formData.filename!,
            bytes: await formData.part.readBytes(),
          )
        else
          formData.name: await formData.part.readString(),
    };

    return await _returnResponseOrError(() async {
      final body0 = <String, MultipartFile>{}; //Uint8List
      requestFormData.forEach((key, value) {
        if (value is MultipartFile) {
          body0[key] = value;
        }
      });

      final request1 = request;

      return await file(body0, request1);
    });
  }

  Future<dynamic> _formHandler(Request request) async {
    if (!request.isMultipart || !request.isMultipartForm) {
      throw RestException.badRequest(message: "request is not form");
    }
    final requestFormData = <String, dynamic>{
      await for (final formData in request.multipartFormData)
        if (formData.filename != null)
          formData.name: MultipartFile(
            name: formData.filename!,
            bytes: await formData.part.readBytes(),
          )
        else
          formData.name: await formData.part.readString(),
    };

    return await _returnResponseOrError(() async {
      final body0 = <String, String>{};
      requestFormData.forEach((key, value) {
        if (value is String) {
          body0[key] = value;
        }
      });

      final body1 = <String, MultipartFile>{}; //Uint8List
      requestFormData.forEach((key, value) {
        if (value is MultipartFile) {
          body1[key] = value;
        }
      });

      return await form(body0, body1);
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
