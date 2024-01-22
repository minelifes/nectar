class UserCreateRequest {
  final String name;
  final String lastName;
  final String phone;
  final String? email;
  final String password;

  const UserCreateRequest(
      {required this.name,
      required this.lastName,
      required this.phone,
      this.email,
      required this.password});

  factory UserCreateRequest.fromJson(Map<String, dynamic> json) =>
      UserCreateRequest(
        name: json["name"],
        lastName: json["lastName"],
        phone: json["phone"],
        email: json["email"],
        password: json["password"],
      );
}
