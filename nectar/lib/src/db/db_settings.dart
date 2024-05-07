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

  DbSettings copyWith({
    String? host,
    int? port,
    String? user,
    String? password,
    String? db,
    int? maxConnections,
    bool? secure,
    String? prefix,
    String? collation,
    bool? sqlEscape,
    bool? pool,
    bool? debug,
  }) =>
      DbSettings(
        host: host ?? this.host,
        port: port ?? this.port,
        user: user ?? this.user,
        password: password ?? this.password,
        db: db ?? this.db,
        maxConnections: maxConnections ?? this.maxConnections,
        secure: secure ?? this.secure,
        prefix: prefix ?? this.prefix,
        collation: collation ?? this.collation,
        sqlEscape: sqlEscape ?? this.sqlEscape,
        pool: pool ?? this.pool,
        debug: debug ?? this.debug,
      );

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
