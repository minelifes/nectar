import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:logger/logger.dart';
import 'package:nectar/src/types/types.dart';

import 'jwt_payload.dart';

class JwtSecurity {
  String? _secretKey;
  String? _rsaPublicKey;
  String? _rsaPrivateKey;
  String? _ecPrivateKey;
  String? _ecPublicKey;
  final _log = Logger();
  late JwtPayloadToUser userDetailsFromPayload;

  JwtSecurity({
    required this.userDetailsFromPayload,
    String? secretKey,
    String? rsaPrivateKey,
    String? rsaPublicKey,
    String? ecPrivateKey,
    String? ecPublicKey,
  }) {
    assert(
        secretKey != null ||
            rsaPrivateKey != null ||
            ecPrivateKey != null ||
            ecPublicKey != null ||
            rsaPublicKey != null,
        "one of secure methods is required!");

    _secretKey = secretKey;
    _rsaPublicKey = rsaPublicKey;
    _rsaPrivateKey = rsaPrivateKey;
    _ecPrivateKey = ecPrivateKey;
    _ecPublicKey = ecPublicKey;
  }

  JWTKey _getSecretKey() {
    if (_secretKey != null) {
      return SecretKey(_secretKey!);
    }
    if (_rsaPrivateKey != null) {
      return RSAPrivateKey(_rsaPrivateKey!);
    }
    return ECPrivateKey(_ecPrivateKey!);
  }

  JWTKey _getPublicKey() {
    if (_secretKey != null) {
      return SecretKey(_secretKey!);
    }
    if (_rsaPublicKey != null) {
      return RSAPublicKey(_rsaPublicKey!);
    }
    return ECPublicKey(_ecPublicKey!);
  }

  bool isTokenValid(String token) =>
      JWT.tryVerify(token, _getPublicKey()) != null;

  JwtPayload? getPayload(String token) {
    try {
      final jwt = JWT.verify(token, _getPublicKey());
      return JwtPayload.fromJson(jwt.payload);
    } catch (e) {
      _log.e("Can't get payload: ${e.toString()}");
      return null;
    }
  }

  String generateToken(JwtPayload payload) {
    return JWT(payload.toJson(), issuer: "Nectar JWT").sign(_getSecretKey());
  }
}
