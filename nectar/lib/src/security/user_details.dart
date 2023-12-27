abstract class UserDetails {
  dynamic getUserModel();

  String get password;
  String get name;
  String? get email;
  String? get login;
  bool get isBlocked;

  bool allowedWithRole(List<String> roles);
  bool allowedWithPrivilege(List<String> privileges);
}
