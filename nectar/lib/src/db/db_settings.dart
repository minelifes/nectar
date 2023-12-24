class DbSettings {
  final String host;
  final int port;
  final String user;
  final String password;
  final String db;
  final int maxConnections;
  final bool secure;
  final String prefix;
  final String collation;
  final bool sqlEscape;
  final bool pool;
  final bool debug;

  const DbSettings({
    required this.host,
    required this.user,
    required this.password,
    required this.db,
    this.port = 3306,
    this.maxConnections = 10,
    this.secure = false,
    this.prefix = "",
    this.collation = "utf8mb4_general_ci",
    this.sqlEscape = true,
    this.pool = true,
    this.debug = false,
  });

  Map<String, dynamic> toMap() => {
        'host': host,
        'port': port,
        'user': user,
        'password': password,
        'db': db,
        'maxConnections': maxConnections,
        'secure': secure,
        'prefix': prefix,
        'pool': pool,
        'collation': collation,
        'sqlEscape': sqlEscape,
      };
}
