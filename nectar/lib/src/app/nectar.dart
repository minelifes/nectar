import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:nectar/nectar.dart';

typedef RouterConfigurer = Handler Function(RouterPlus);

class Nectar {
  Nectar._() {
    GetIt.I.registerSingleton<Nectar>(this);
  }

  static ScopeKey<NectarContext> context = ScopeKey<NectarContext>("tenant_db");

  factory Nectar.configure() => Nectar._();

  bool _isJwtConfigured = false;
  bool _shared = false;

  bool get isJwtConfigured => _isJwtConfigured;

  Function? _onStarted;
  Function(String msg)? _onStartFailed;
  Function? _onWillClose;
  Function? _onClose;

  String _host = "0.0.0.0";
  int _port = 8080;
  SecurityContext? _context;
  bool _enableHotReload = false;

  TenantLoader? _tenantLoader;

  Middleware? _corsMiddleware;

  Middleware get corsMiddleware => _corsMiddleware ?? corsHeaders();

  TenantLoader? get tenantLoader => _tenantLoader;

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

  Nectar setShared(bool shared) {
    _shared = shared;
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

  Nectar useCors({
    Map<String, String>? headers,
    OriginChecker? originChecker,
  }) {
    _corsMiddleware = corsHeaders(
        headers: headers, originChecker: originChecker ?? originAllowAll);
    return this;
  }

  Nectar useCustomMiddlewareForCORS(Middleware middleware) {
    _corsMiddleware = middleware;
    return this;
  }

  Nectar withDefaultConnection(DbSettings settings) {
    settings.toMap();
    final db = Db.configure();
    db.defaultConnection = db.newConnection(settings);
    return this;
  }

  Nectar withTenants(TenantLoader loader) {
    _tenantLoader = loader;
    return this;
  }

  Future<ShelfRunContext> start({RouterConfigurer? configurer}) async {
    final server = await shelfRun(
      () {
        var router = Routes.getRouter();
        if (_corsMiddleware != null) {
          router.options("/**", () async {
            return Response.ok("");
          }, use: _corsMiddleware);
        }
        if (configurer != null) {
          return configurer(router);
        }
        return router;
      },
      defaultBindPort: _port,
      defaultBindAddress: _host,
      defaultEnableHotReload: _enableHotReload,
      defaultShared: _shared,
      securityContext: _context,
      onStarted: (h, p) {
        logger.i(
            'Running at ${_context != null ? "https://" : "http://"}$h:$p${(_isJwtConfigured ? " with JWT security" : "")}');
        _onStarted?.call();
      },
      onStartFailed: (msg) {
        logger.e("Can't start server details: ${msg.toString()}");
        _onStartFailed?.call(msg.toString());
      },
      onWillClose: () {
        logger.i("Server stopping.");
        try {
          inject<Db>()?.close();
        } catch (_) {}
        try {
          _onWillClose?.call();
        } catch (_) {}
      },
      onClosed: () {
        logger.i("Server stopped.");
        _onClose?.call();
      },
    );

    return server;
  }
}
