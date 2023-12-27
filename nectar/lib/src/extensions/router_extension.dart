import 'dart:collection';

import 'package:shelf_plus/shelf_plus.dart';

extension RouterParams on Request {
  /// usage request.params['name'];
  Map<String, String> get params {
    final p = context['shelf_router/params'];
    if (p is Map<String, String>) {
      return UnmodifiableMapView(p);
    }
    return {};
  }
}
