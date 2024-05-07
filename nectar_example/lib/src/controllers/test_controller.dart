import 'package:nectar/nectar.dart';
import 'package:nectar_example/src/media.dart';
import 'package:nectar_example/src/payloads/test_request.dart';
import 'package:nectar_example/src/role.dart';
import 'package:nectar_example/src/user.dart';

part 'test_controller.g.dart';

@RestController(path: "/api/v1/users")
class _TestController {
  @GetMapping("/")
  Future<List<Role>> getRoles() async {
    return [Role()..name = "myTitle"];
  }

  @GetMapping("/int/<id>")
  Future<String?> getIntById(@PathVariable(name: "id") int id) async {
    return "$id";
  }

  @PostMapping("/body")
  @AuthWithJwt()
  Future<Map<String, dynamic>> testBody(
      @RequestBody() TestRequest request) async {
    return {
      "request": await MediaEntity.query().select().where().id("frame2").isMain(true, condition: "OR").one(),
      "userDetails": (requestContext.userDetails?.getUserModel() as User?)?.toJson()
    };
  }

  @GetMapping("/secured")
  @AuthWithJwt()
  @HasRole(["admin"])
  Future<List<Role>> secured() async {
    return [Role()..name = "myTitle"];
  }

  @GetMapping("/login")
  Future<String> login() async {
    return getIt.get<JwtSecurity>().generateToken(JwtPayload(id: 2));
  }

  @PostMapping("/file")
  @AcceptMultipartFormData()
  Future<String> file(
      @Files() Map<String, MultipartFile> files, Request request) async {
    return getIt.get<JwtSecurity>().generateToken(JwtPayload(id: 2));
  }

  @PostMapping("/form")
  @AcceptMultipartFormData()
  Future<String> form(
    @MapFormData() Map<String, String> data,
    @Files() Map<String, MultipartFile> files,
  ) async {
    print("Map: ");
    data.forEach((key, value) {
      print("$key:$value");
    });
    print("\n\nFiles: ");
    files.forEach((key, value) {
      print("$key:$value");
    });
    return getIt.get<JwtSecurity>().generateToken(JwtPayload(id: 2));
  }

  @GetMapping("/<id>")
  Future<Role?> getById(@PathVariable(name: "id") String id) async {
    return Role()
      ..name = "myTitle"
      ..key = id;
  }
}
