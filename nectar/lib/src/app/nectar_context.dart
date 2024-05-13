import 'package:nectar/nectar.dart';

class NectarContext {
  String? _tenant;
  String? _token;
  UserDetails? _userDetails;
  Map<String, dynamic> _storage = {};

  NectarContext({String? tenant, UserDetails? user, String? token}){
    _tenant = tenant;
    _userDetails = user;
    _token = token;
  }

  void putAll(Map<String, dynamic> other) => _storage.addAll(other);

  void put(String key, dynamic data) => _storage[key] = data;
  void putString(String key, String data) => put(key, data);
  void putInt(String key, int data) => put(key, data);
  void putDouble(String key, double data) => put(key, data);
  void putBool(String key, bool data) => put(key, data);

  void remove(String key) => _storage.remove(key);

  T? read<T>(String key) => _storage[key] as T?;
  int? readInt(String key) => read(key);
  String? readString(String key) => read(key);
  double? readDouble(String key) => read(key);
  bool? readBool(String key) => read(key);

  void clean() => _storage = {};

  Map<String, dynamic> get storage => _storage;

  void updateTenant(String? tenant){
    _tenant = tenant;
  }

  void updateToken(String? token){
    _token = token;
  }

  void updateUser(UserDetails? user){
    _userDetails = user;
  }

  String? get tenant => _tenant;
  UserDetails? get userDetails => _userDetails;
  String? get token => _token;

  @override
  String toString() {
    return "NectarContext(tenant: '$_tenant', user: ${_userDetails?.getUserModel()})";
  }
}