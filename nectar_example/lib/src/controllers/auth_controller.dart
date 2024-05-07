import 'package:nectar/nectar.dart';
import 'package:nectar_example/src/dtos/user_dto.dart';
import 'package:nectar_example/src/payloads/auth_request.dart';
import 'package:nectar_example/src/payloads/user_request.dart';
import 'package:nectar_example/src/user.dart';

part 'auth_controller.g.dart';

@RestController(path: "/api/v1/auth")
class _AuthController {
  @PostMapping('/register')
  Future<UserDTO> registerUser(
    @RequestBody() UserCreateRequest request,
  ) async {
    final existUser =
        await User.query().select().where().one();
    if (existUser != null) {
      throw RestException.itemAlreadyExist("User");
    }

    final userData = User()
      ..name = request.name
      ..lastName = request.lastName
      ..email = request.email
      ..phone = request.phone
      ..password = request.password.toHashedPassword()
      ..isBlocked = false;
    final user = await userData.save();
    if (user == null) {
      throw RestException(
        message: "Can't save user",
      );
    }
    try {
      final token = getIt.get<JwtSecurity>().generateToken(
            JwtPayload(
                id: user.id!,
                userLogin: user.email,
                userName: "${user.lastName} ${user.name}",
                createdAt: DateTime.now()),
          );
      return user.toDto(token);
    } catch (_) {
      throw RestException(message: "Can't save user");
    }
  }

  @PostMapping('/login')
  @AddHeaders({"TestHeader": "asdfsfg"})
  Future<UserDTO> login(@RequestBody() AuthRequest request) async {
    print(use(Nectar.context).toString());

    final user = await User.query().select().where().email(request.email).one();
    print("user: ${user}");
    if (user == null) {
      throw RestException.unauthorized(
        message: "User with this data not found!",
      );
    }
    if (!request.password.isPasswordEq(user.password)) {
      throw RestException.unauthorized(
        message: "User with this data not found!",
      );
    }
    print(user);
    final token = getIt.get<JwtSecurity>().generateToken(
          JwtPayload(
              id: user.id!,
              userLogin: user.email,
              userName: "${user.lastName} ${user.name}",
              createdAt: DateTime.now()),
        );
    return user.toDto(token);
  }
}
