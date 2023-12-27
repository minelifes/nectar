class RestController {
  final String? path;
  const RestController({this.path});
}

class GetMapping {
  final String path;
  final String method = "GET";
  const GetMapping(this.path);
}

class PostMapping {
  final String path;
  final String method = "POST";
  const PostMapping(this.path);
}

class PutMapping {
  final String path;
  final String method = "PUT";
  const PutMapping(this.path);
}

class DeleteMapping {
  final String path;
  final String method = "DELETE";
  const DeleteMapping(this.path);
}

class PatchMapping {
  final String path;
  final String method = "PATCH";
  const PatchMapping(this.path);
}

class Mapping {
  final String path;
  final String method = "ALL";
  const Mapping(this.path);
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
