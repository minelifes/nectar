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

///Apply to field to accept path variable '/ads/<id>' @PathVariable(name: "id") String pathVar
class PathVariable {
  final String? name;
  final dynamic defaultValue;
  const PathVariable({this.name, this.defaultValue});
}

///Apply to field to accept query variable ?a=... @QueryVariable(name: "a") String aVariable
class QueryVariable {
  final String? name;
  final dynamic defaultValue;
  const QueryVariable({this.name, this.defaultValue});
}

///Apply to field to accept json data into Model which should have fromJson factory or constructor
class RequestBody {
  const RequestBody();
}

///Apply to method if need to check role access before proceed
class HasRole {
  final List<String> value;
  final String methodName;
  const HasRole(this.value, {this.methodName = "hasRoleMiddleware"});
}

///Apply to method if need to check privilege access before proceed
class HasPrivilege {
  final List<String> value;
  final String methodName;
  const HasPrivilege(this.value, {this.methodName = "hasPrivilegeMiddleware"});
}

///Apply to method if need to handle jwt token and user data
class AuthWithJwt {
  final String methodName;
  const AuthWithJwt({this.methodName = "checkJwtMiddleware"});
}

///Apply to method if need to response custom headers
class AddHeaders {
  final Map<String, String> headers;
  const AddHeaders(this.headers);
}

///Apply to method if accept formData
class AcceptMultipartFormData {
  const AcceptMultipartFormData();
}

// ///Apply to method if accept formData
// class AcceptFormData {
//   const AcceptFormData();
// }

///Apply to field if need to get raw RawFormData (List<FormData>)
class RawFormData {
  const RawFormData();
}

///Apply to field if field accept file/s (Map<String, Uint8List>)
class Files {
  const Files();
}

///Apply to field if field accept FormData / MultipartFormData (Map<String, dynamic>)
class MapFormData {
  const MapFormData();
}
