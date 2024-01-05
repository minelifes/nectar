import 'package:bcrypt/bcrypt.dart';

class PasswordUtils {
  static String hash(String passwd, {int rounds = 10}) =>
      BCrypt.hashpw(passwd, BCrypt.gensalt(logRounds: rounds));
  static bool isPasswordEq(String passwd, String hashed) =>
      BCrypt.checkpw(passwd, hashed);
}

extension PasswordUtilsExt on String {
  String toHashedPassword() => PasswordUtils.hash(this);
  bool isPasswordEq(String hashed) => PasswordUtils.isPasswordEq(this, hashed);
}
