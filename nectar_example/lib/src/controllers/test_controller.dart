import 'dart:convert';
import 'dart:mirrors';

import 'package:nectar/nectar.dart';
import 'package:nectar_example/src/payloads/test_request.dart';
import 'package:nectar_example/src/role.dart';
import 'package:shelf/shelf.dart';

part 'test_controller.g.dart';

@RestController(path: "/api/v1/users")
class _TestController {
  @GetMapping("/")
  Future<List<Role>> getRoles() async {
    return [Role()..title = "myTitle"];
  }

  @GetMapping("/<id>")
  Future<Role?> getById(@PathVariable(name: "id") String id) async {
    return Role()
      ..title = "myTitle"
      ..id = id;
  }

  @GetMapping("/int/<id>")
  Future<String?> getIntById(@PathVariable(name: "id") int id) async {
    return "$id";
  }

  @PostMapping("/body")
  @AuthWithJwt()
  Future<TestRequest?> testBody(@RequestBody() TestRequest request) async {
    return request;
  }

  @GetMapping("/secured")
  @AuthWithJwt()
  @RequiredRole("admin")
  Future<List<Role>> secured() async {
    return [Role()..title = "myTitle"];
  }

  @GetMapping("/login")
  Future<String> login() async {
    return getIt.get<JwtSecurity>().generateToken(JwtPayload(id: 2));
  }
}
