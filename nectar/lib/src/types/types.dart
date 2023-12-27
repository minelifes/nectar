import 'package:nectar/nectar.dart';
import 'package:nectar/src/security/user_details.dart';
import 'package:shelf_plus/shelf_plus.dart';

typedef NectarConfigurer = void Function(RouterPlus router);

typedef JwtPayloadToUser = Future<UserDetails?> Function(JwtPayload payload);
