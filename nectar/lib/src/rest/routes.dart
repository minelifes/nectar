import 'package:logger/logger.dart';
import 'package:nectar/src/types/types.dart';
import 'package:shelf_plus/shelf_plus.dart';

class Routes {
  static final _router = Router().plus;
  static final List<NectarConfigurer> _routes = [];

  static void registerRoute(NectarConfigurer route) {
    _routes.add(route);
  }

  static int get registeredControllers => _routes.length;

  static Handler getRouter() {
    for (var e in _routes) {
      e(_router);
    }
    if (_routes.isEmpty) {
      Logger().w("Server don't have registered routes.");
    }
    return _router;
  }
}
