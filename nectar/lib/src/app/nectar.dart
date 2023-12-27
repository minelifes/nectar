import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nectar/nectar.dart';
import 'package:shelf_plus/shelf_plus.dart';

class Nectar {
  final _log = Logger();

  Nectar._() {
    GetIt.I.registerSingleton<Nectar>(this);
  }

  factory Nectar.configure() => Nectar._();

  bool _isJwtConfigured = false;
  bool get isJwtConfigured => _isJwtConfigured;

  Function? _onStarted;
  Function(String msg)? _onStartFailed;
  Function? _onWillClose;
  Function? _onClose;

  String _host = "0.0.0.0";
  int _port = 8080;
  SecurityContext? _context;
  bool _enableHotReload = false;

  Nectar onStart(Function method) {
    _onStarted = method;
    return this;
  }

  Nectar onStartFailed(Function(String msg) method) {
    _onStartFailed = method;
    return this;
  }

  Nectar onWillClose(Function method) {
    _onWillClose = method;
    return this;
  }

  Nectar onClose(Function method) {
    _onClose = method;
    return this;
  }

  Nectar setHost(String host) {
    _host = host;
    return this;
  }

  Nectar setPort(int port) {
    _port = port;
    return this;
  }

  Nectar setContext(SecurityContext context) {
    _context = context;
    return this;
  }

  Nectar enableHotReload() {
    _enableHotReload = true;
    return this;
  }

  Nectar enableJwtSecurity(JwtSecurity security) {
    GetIt.I.registerSingleton<JwtSecurity>(security);
    _isJwtConfigured = true;
    return this;
  }

  Future<ShelfRunContext> start() async {
    final server = await shelfRun(() => Routes.getRouter(),
        defaultBindPort: _port,
        defaultBindAddress: _host,
        defaultEnableHotReload: _enableHotReload,
        securityContext: _context, onStarted: (h, p) {
      _log.i(
          'Running at http://$h:$p${(_isJwtConfigured ? " with JWT security" : "")}');
      _onStarted?.call();
    }, onStartFailed: (msg) {
      _log.e("Can't start server details: ${msg.toString()}");
      _onStartFailed?.call(msg.toString());
    }, onWillClose: () {
      _log.i("Server stopping.");
      _onWillClose?.call();
    }, onClosed: () {
      _log.i("Server stopped.");
      _onClose?.call();
    });

    return server;
  }
}
