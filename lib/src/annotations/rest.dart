class RestController {
  final String? path;
  const RestController({this.path});
}

class GetMapping {
  final String path;
  const GetMapping(this.path);
}

class PostMapping {
  final String path;
  const PostMapping(this.path);
}

class PutMapping {
  final String path;
  const PutMapping(this.path);
}

class DeleteMapping {
  final String path;
  const DeleteMapping(this.path);
}

class PathVariable {
  final String? name;
  const PathVariable({this.name});
}

class QueryVariable {
  final String? name;
  final dynamic defaultValue;
  const QueryVariable({this.name, this.defaultValue});
}

class RequestBody {
  final String name;
  const RequestBody(this.name);
}
