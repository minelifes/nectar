class RestController {
  final String? path;
  const RestController({this.path});
}

class GetMapping {
  final String path;
  final String method = "GET";
  final String contentType;
  final Map<String, String> headers;
  const GetMapping(
    this.path, {
    this.headers = const {},
    this.contentType = "application/json",
  });
}

class PostMapping {
  final String path;
  final String method = "POST";
  final String contentType;
  final Map<String, String> headers;
  const PostMapping(
    this.path, {
    this.headers = const {},
    this.contentType = "application/json",
  });
}

class PutMapping {
  final String path;
  final String method = "PUT";
  final String contentType;
  final Map<String, String> headers;
  const PutMapping(
    this.path, {
    this.headers = const {},
    this.contentType = "application/json",
  });
}

class DeleteMapping {
  final String path;
  final String method = "DELETE";
  final String contentType;
  final Map<String, String> headers;
  const DeleteMapping(
    this.path, {
    this.headers = const {},
    this.contentType = "application/json",
  });
}

class PatchMapping {
  final String path;
  final String method = "PATCH";
  final String contentType;
  final Map<String, String> headers;
  const PatchMapping(
    this.path, {
    this.headers = const {},
    this.contentType = "application/json",
  });
}

class Mapping {
  final String path;
  final String method = "ALL";
  final String contentType;
  final Map<String, String> headers;
  const Mapping(
    this.path, {
    this.headers = const {},
    this.contentType = "application/json",
  });
}

class PathVariable {
  final String? name;
  final dynamic defaultValue;
  const PathVariable({this.name, this.defaultValue});
}

class QueryVariable {
  final String? name;
  final dynamic defaultValue;
  const QueryVariable({this.name, this.defaultValue});
}

class RequestBody {
  const RequestBody();
}

class RequiredRole {
  final String name;
  const RequiredRole(this.name);
}

class HasRole {
  final List<String> value;
  final String methodName;
  const HasRole(this.value, {this.methodName = "hasRoleMiddleware"});
}

class HasPrivilege {
  final List<String> value;
  final String methodName;
  const HasPrivilege(this.value, {this.methodName = "hasPrivilegeMiddleware"});
}

class AuthWithJwt {
  final String methodName;
  const AuthWithJwt({this.methodName = "checkJwtMiddleware"});
}

class AddHeaders {
  final Map<String, String> headers;
  const AddHeaders(this.headers);
}
