class AuthRequest {
  final String email;
  final String password;

  const AuthRequest({
    required this.email,
    required this.password,
  });

  factory AuthRequest.fromJson(Map<String, dynamic> json) => AuthRequest(
    email: json["email"],
    password: json["password"],
  );
}
