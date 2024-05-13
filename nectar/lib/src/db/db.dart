import 'package:nectar/nectar.dart';
import 'package:nectar/src/callbacks/callbacks.dart';

class Db {
  Db._() {
    registerSingleton<Db>(this);
  }

  factory Db.configure() => Db._();

  MysqlUtils? defaultConnection;
  DbSettings? _settings;

  bool debug = false;

  final Map<String, MysqlUtils> _tenants = {};

  Future<MysqlUtils?>? get _utils async {
    if (hasScopeKey(Nectar.context) && inject<Nectar>()!.tenantLoader != null) {
      try {
        final context = use(Nectar.context);
        if (context.tenant == null) return defaultConnection;
        if (_tenants.containsKey(context.tenant)) {
          return _tenants[context.tenant];
        }
        final loader = inject<Nectar>()!.tenantLoader!;
        if (!(await loader.isProjectValid(context.tenant!))) {
          return null;
        }
        final config = await loader.dbForTenant(context.tenant!, _settings);
        final con = newConnection(config);
        _tenants[context.tenant!] = con;
        return con;
      }catch(_){
        return null;
      }
    }
    if (defaultConnection == null) {
      return null;
    }
    return defaultConnection;
  }

  Future<MysqlUtils> _getConnectionOrThrow() async {
    final conn = await _utils;
    if(conn == null) {
      throw RestException(
        message: "Tenant not found or can't create connection!");
    }
    return conn;
  }

  void _onError(error) {
    logger.e(error);
  }

  void _onSql(sql) {
    if (!debug) return;
    logger.i(sql);
  }

  void _onConnect(db1) {
    if (!debug) return;
    logger.d(db1);
  }

  Future<void> close() async {
    for (var tenant in _tenants.values) {
      await tenant.close();
    }
    _tenants.clear();
    await defaultConnection?.close();
  }

  MysqlUtils newConnection(
    DbSettings settings, {
    ValueCallback<String>? onError,
    ValueCallback<String>? sqlLog,
    ValueCallback<dynamic>? onConnected,
  }) {
    debug = settings.debug;
    _settings = settings;
    return MysqlUtils(
      settings: settings.toMap(),
      errorLog: onError ?? _onError,
      sqlLog: sqlLog ?? _onSql,
      connectInit: onConnected ?? _onConnect,
    );
  }

  Future<ResultFormat> query(
    String sql, {
    Map<String, dynamic> values = const {},
    List<JoinModel> joins = const [],
    String forTable = "",
  }) async =>
      (await _getConnectionOrThrow()).query(
        sql,
        values: values,
        debug: debug,
        joins: joins,
        forTable: forTable,
      );

  Future<ResultFormat> createTableIfNotExist({
    required String tableName,
    required List<ColumnInfo> columns,
  }) async =>
      (await _getConnectionOrThrow()).createTableIfNotExist(table: tableName, columns: columns);

  Future<List<int>> queryMulti(
          String sql, Iterable<List<Object?>> values) async =>
      (await _getConnectionOrThrow()).queryMulti(sql, values, debug: debug);

  Future<Map> getOne({
    required String table,
    List<String> fields = const [],
    where = const {},
    String group = '',
    String having = '',
    String order = '',
    List<JoinModel> joins = const [],
  }) async =>
      (await _getConnectionOrThrow()).getOne(
          table: table,
          fields: fields,
          where: where,
          group: group,
          having: having,
          order: order,
          debug: debug,
          joins: joins);

  Future<List<dynamic>> getAll({
    required String table,
    List<String> fields = const [],
    where = const {},
    String order = '',
    int limit = 100,
    int startFrom = 0,
    String group = '',
    String having = '',
    List<JoinModel> joins = const [],
  }) async =>
      (await _getConnectionOrThrow()).getAll(
        table: table,
        fields: fields,
        where: where,
        order: order,
        limit: [startFrom, limit],
        group: group,
        having: having,
        debug: debug,
        joins: joins,
      );

  Future<dynamic> insertOrUpdate({
    required String table,
    required Map<String, dynamic> insertData,
    required String primaryKeyName,
  }) async =>
      (await _getConnectionOrThrow()).insertOrUpdate(
        primaryKeyName: primaryKeyName,
        table: table,
        insertData: insertData,
        debug: debug,
      );

  Future<int> insertAll({
    required String table,
    required List<Map<String, dynamic>> insertData,
    required String primaryKeyName,
    replace = false,
  }) async =>
      (await _getConnectionOrThrow()).insertAll(
        primaryKeyName: primaryKeyName,
        table: table,
        insertData: insertData,
        replace: replace,
        debug: debug,
      );

  Future<int> delete({
    required String table,
    required where,
  }) async =>
      (await _getConnectionOrThrow()).delete(
        table: table,
        where: where,
        debug: debug,
      );

  Future<Paginated> paginated<T extends Model>({
    required String table,
    required int page,
    int perPage = 20,
    List<String> fields = const [],
    where = const {},
    String order = '',
    String group = '',
    String having = '',
    List<JoinModel> joins = const [],
    required T Function(dynamic) instanceOfT,
  }) async =>
      (await _getConnectionOrThrow()).paginated<T>(
          table: table,
          perPage: perPage,
          fields: fields,
          where: where,
          order: order,
          group: group,
          having: having,
          debug: debug,
          joins: joins,
          page: page,
          instanceOfT: instanceOfT);
}
