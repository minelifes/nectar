import 'package:nectar/nectar.dart';
import 'package:nectar_example/src/user.dart';

class AppUserDetails extends UserDetails {
  final User user;
  AppUserDetails(this.user);

  @override
  bool allowedWithPrivilege(List<String> privileges) => true;

  @override
  bool allowedWithRole(List<String> roles) {
    //TODO fix here to create valid logic
    if(roles.contains("user")) return true;
    if(roles.contains("admin")) return true; //roles.contains(user.role.id)
    return false;
  }

  @override
  String? get email => user.email;

  @override
  getUserModel() => user;

  @override
  bool get isBlocked => user.isBlocked;

  @override
  String? get login => user.email;

  @override
  String get name => "${user.lastName} ${user.name}";

  @override
  String get password => user.password;
}
