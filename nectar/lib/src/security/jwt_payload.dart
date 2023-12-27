class JwtPayload {
  dynamic id;
  String? userName;
  String? userLogin;
  late DateTime createdAt;

  JwtPayload({
    required this.id,
    this.userLogin,
    this.userName,
    DateTime? createdAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'userLogin': userLogin,
        'createdAt': createdAt.toIso8601String(),
      };

  factory JwtPayload.fromJson(Map<String, dynamic> json) => JwtPayload(
        id: json['id'],
        userLogin: json['userLogin'],
        userName: json['userName'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
