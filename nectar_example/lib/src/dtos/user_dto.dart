import 'package:nectar_example/src/role.dart';
import 'package:nectar_example/src/user.dart';

extension UserDTOExt on User {
  UserDTO toDto(String token) => UserDTO.fromUser(this, token);
}

class UserDTO {
  final int id;
  final String phone;
  final String? email;
  final String name;
  final String lastName;
  final bool isBlocked;
  final Role role;
  final String token;

  const UserDTO({
    required this.id,
    required this.phone,
    required this.email,
    required this.name,
    required this.lastName,
    required this.isBlocked,
    required this.role,
    required this.token,
  });

  factory UserDTO.fromUser(User entity, String token) => UserDTO(
    id: entity.id!,
    phone: entity.phone,
    email: entity.email,
    name: entity.name,
    lastName: entity.lastName,
    isBlocked: entity.isBlocked,
    role: entity.role,
    token: token,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "phone": phone,
    "email": email,
    "name": name,
    "lastName": lastName,
    "isBlocked": isBlocked,
    "role": role.toJson(),
    "token": token,
  };
}
