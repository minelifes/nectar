import 'dart:async';
import 'package:mysql_client/mysql_client.dart';
import 'package:collection/collection.dart';
import 'package:nectar/nectar.dart';

///mysql helper
class MysqlUtils {
  ///pool connect
  late Future<MySQLConnectionPool> poolConn;

  ///single connect
  late Future<MySQLConnection> singleConn;

  ///mysql setting
  late Map _settings = {};

  ///transaction start
  int transTimes = 0;

  ///sql error log
  final Function? errorLog;

  /// show sql log
  final Function? sqlLog;

  /// sqlEscape
  bool sqlEscape = false;

  ///
  final Function? connectInit;
  factory MysqlUtils({
    required Map settings,
    Function? errorLog,
    Function? sqlLog,
    Function? connectInit,
  }) {
    return MysqlUtils._internal(settings, sqlLog, errorLog, connectInit);
  }

  MysqlUtils._internal([
    Map? settings,
    this.sqlLog,
    this.errorLog,
    this.connectInit,
  ]) {
    if (settings != null) {
      _settings = settings;
      sqlEscape = settings['sqlEscape'] ?? false;
    } else {
      throw ('settings is null');
    }
    if (_settings['pool']) {
      poolConn = createConnectionPool(settings);
    } else {
      singleConn = createConnectionSingle(settings);
    }
  }

  ///create single connection
  Future<MySQLConnection> createConnectionSingle(Map settings) async {
    final conn = await MySQLConnection.createConnection(
      host: settings['host'] ?? '127.0.0.1',
      port: settings['port'] ?? 3306,
      userName: settings['user'] ?? '',
      password: settings['password'] ?? '',
      databaseName: settings['db'] ?? '', // optional,
      secure: settings['secure'] ?? false,
      collation: settings['collation'] ?? 'utf8mb4_general_ci',
    );
    await conn.connect();
    return conn;
  }

  ///create pool connection
  Future<MySQLConnectionPool> createConnectionPool(Map settings) async {
    return MySQLConnectionPool(
      host: settings['host'] ?? '127.0.0.1',
      port: settings['port'] ?? 3306,
      userName: settings['user'] ?? '',
      password: settings['password'] ?? '',
      maxConnections: settings['maxConnections'] ?? 10,
      databaseName: settings['db'] ?? '', // optional,
      secure: settings['secure'] ?? false,
      collation: settings['collation'] ?? 'utf8mb4_general_ci',
    );
  }

  ///isConnectionAlive
  Future<bool> isConnectionAlive() async {
    try {
      await query('select 1').timeout(Duration(milliseconds: 500),
          onTimeout: () {
        throw TimeoutException('test isConnectionAlive timeout.');
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ```
  ///await db.startTrans();
  /// ```
  Future<void> startTrans() async {
    if (transTimes == 0) {
      transTimes++;
      await query('start transaction');
    } else {
      throw ('Only supports startTrans once');
    }
  }

  /// ```
  ///db.commit();
  /// ```
  Future<void> commit() async {
    if (transTimes > 0) {
      await query('commit');
      transTimes = 0;
    }
  }

  /// ```
  ///db.rollback();
  /// ```
  Future<void> rollback() async {
    if (transTimes > 0) {
      await query('rollback');
      transTimes = 0;
    }
  }

  /// ```
  /// await db.delete(
  ///   table:'table',
  ///   where: {'id':1}
  /// );
  /// ```
  Future<int> delete({
    required String table,
    required where,
    bool debug = false,
  }) async {
    table = _tableParse(table);
    String _where = _whereParse(where);
    ResultFormat results =
        await query('DELETE FROM $table $_where ', debug: debug);
    return results.affectedRows;
  }

  ///```
  /// await db.update(
  ///   table: 'table',
  ///   updateData:{
  ///     'telphone': '1231',
  ///     'create_time': 12,
  ///     'update_time': 12121212,
  ///     'email': 'biner@dd.com'
  ///   },
  ///   where:{
  ///   'id':1,
  /// });
  ///```
  Future<ResultFormat> update({
    required String table,
    required Map<String, dynamic> updateData,
    required where,
    required String primaryKeyName,
    bool debug = false,
  }) async {
    table = _tableParse(table);
    String _where = _whereParse(where);

    if (updateData.isEmpty) {
      throw ('updateData.length!=0');
    }

    List<String> _setkeys = [];
    updateData.forEach((key, value) {
      _setkeys.add('`$key` = :$key ');
    });

    String _setValue = _setkeys.join(',');
    String _sql = 'UPDATE $table SET $_setValue $_where';
    ResultFormat results = await query(
      _sql,
      values: updateData,
      debug: debug,
    );
    return results;
  }

  ///
  /// return affectedRows
  ///```
  /// await db.insertAll(
  ///   table: 'table',
  ///   insertData: [
  ///       {
  ///         'telphone': '13888888888',
  ///         'create_time': 1111111,
  ///         'update_time': 12121212,
  ///         'email': 'biner@dd.com'
  ///       },
  ///       {
  ///         'telphone': '13881231238',
  ///         'create_time': 324234,
  ///         'update_time': 898981,
  ///         'email': 'xxx@dd.com'
  ///       }
  /// ]);
  ///```

  Future<int> insertAll({
    required String table,
    required List<Map<String, dynamic>> insertData,
    required String primaryKeyName,
    replace = false,
    debug = false,
  }) async {
    if (insertData.isEmpty) {
      throw ('insertData.length!=0');
    }
    table = _tableParse(table);
    List<String> _fields = [];
    List<String> _values = [];
    insertData.first.forEach((key, value) => _fields.add('`$key`'));
    insertData.forEach((val) {
      List _t = [];
      val.forEach((key, value) {
        if (value is num) {
          _t.add(value);
        } else {
          if (value is String) {
            _t.add('\'${sqlEscapeString(value)}\'');
          } else {
            _t.add('\'$value\'');
          }
        }
      });
      _values.add('(${_t.join(',')})');
    });
    String _fieldsString = _fields.join(',');
    String _valuesString = _values.join(',');
    String _sql =
        '${replace ? 'REPLACE' : 'INSERT'} INTO $table ($_fieldsString) VALUES $_valuesString';
    ResultFormat result = await query(_sql, debug: debug);
    return result.affectedRows;
  }

  ///```
  /// return lastInsertID
  ///
  /// await db.insert(
  ///   table: 'table',
  ///   insertData: {
  ///     'telphone': '+113888888888',
  ///     'create_time': 1620577162252,
  ///     'update_time': 1620577162252,
  ///   },
  /// );
  ///```
  Future<dynamic> insertOrUpdate({
    required String table,
    required Map<String, dynamic> insertData,
    required String primaryKeyName,
    debug = false,
  }) async {
    if (insertData.isEmpty) {
      throw ('insertData.length!=0');
    }
    table = _tableParse(table);
    List<String> _fields = [];
    List<String> _values = [];
    insertData.forEach((key, value) {
      _fields.add('$key');
      _values.add(':$key');
      if (sqlEscape && value is String) {
        insertData[key] = sqlEscapeString(value);
      }
    });
    String _fieldsString = _fields.map((e) => "`$e`").join(',');
    String _valuesString = _values.join(',');
    String _sql = 'INSERT INTO $table ($_fieldsString) VALUES ($_valuesString) '
        'ON DUPLICATE KEY UPDATE ${(_fields..remove(primaryKeyName)).map((e) => "`$e`=:$e").join(', ')}';
    final inserted = await query(_sql, values: insertData, debug: debug);
    // if (inserted.affectedRows == 0) throw OrmException("Cant insert data");
    if (insertData.containsKey(primaryKeyName)) {
      final id = insertData[primaryKeyName];
      if (id != null) return id;
    }
    if (inserted.lastInsertID > 0) {
      return inserted.lastInsertID;
    }
    return 1;
  }

  ///```
  /// await db.count(
  ///   table: 'table',
  ///   fields: '*',
  ///   group: 'name',
  ///   having: 'name',
  ///   debug: false,
  ///   where:{
  ///   'id':['>',1],
  ///   }
  /// );
  ///```
  Future<int> count({
    required String table,
    String fields = '*',
    where = const {},
    String group = '',
    String having = '',
    bool debug = false,
  }) async {
    if (group != '') group = 'GROUP BY $group';
    if (having != '') having = 'HAVING $having';

    String _where = _whereParse(where);
    var formattedTable = _tableParse(table);

    ResultFormat results = await query(
        forTable: table,
        'SELECT count($fields) $table\$count FROM $formattedTable $_where $group $having',
        debug: debug);
    return results.rows.first['count'];
  }

  ///```
  /// await db.avg(
  ///   table: 'table',
  ///   fields: '*',
  ///   group: 'name',
  ///   having: 'name',
  ///   debug: false,
  ///   where:{
  ///   'id':['>',1],
  ///   }
  /// );
  ///```
  Future<double> avg({
    required String table,
    String fields = '',
    where = const {},
    String group = '',
    String having = '',
    bool debug = false,
  }) async {
    if (group != '') group = 'GROUP BY $group';
    if (having != '') having = 'HAVING $having';
    if (fields == '') throw 'fields cant be empty';

    String _where = _whereParse(where);
    table = _tableParse(table);

    ResultFormat results = await query(
        'SELECT AVG($fields) as _avg FROM $table $_where $group $having',
        debug: debug);
    return double.parse(results.rows.first['_avg'] ?? '0');
  }

  ///```
  /// await db.max(
  ///   table: 'table',
  ///   fields: '*',
  ///   group: 'name',
  ///   having: 'name',
  ///   debug: false,
  ///   where:{
  ///   'id':['>',1],
  ///   }
  /// );
  ///```
  Future<double> max({
    required String table,
    String fields = '',
    where = const {},
    String group = '',
    String having = '',
    bool debug = false,
  }) async {
    if (group != '') group = 'GROUP BY $group';
    if (having != '') having = 'HAVING $having';
    if (fields == '') throw 'fields cant be empty';

    String _where = _whereParse(where);
    table = _tableParse(table);

    ResultFormat results = await query(
        'SELECT max($fields) as _max FROM $table $_where $group $having',
        debug: debug);
    var n = results.rows.first['_max'];
    if (n is int) {
      return n.toDouble();
    } else {
      return n;
    }
  }

  ///```
  /// await db.min(
  ///   table: 'table',
  ///   fields: '*',
  ///   group: 'name',
  ///   having: 'name',
  ///   debug: false,
  ///   where:{
  ///   'id':['>',1],
  ///   }
  /// );
  ///```
  Future<double> min({
    required String table,
    String fields = '',
    where = const {},
    String group = '',
    String having = '',
    bool debug = false,
  }) async {
    if (group != '') group = 'GROUP BY $group';
    if (having != '') having = 'HAVING $having';
    if (fields == '') throw 'fields cant be empty';
    String _where = _whereParse(where);
    table = _tableParse(table);

    ResultFormat results = await query(
        'SELECT MIN($fields) as _min FROM $table $_where $group $having',
        debug: debug);
    var n = results.rows.first['_min'];
    if (n is int) {
      return n.toDouble();
    } else {
      return n;
    }
  }

  String _joinParse(List<JoinModel> joins) {
    StringBuffer str = StringBuffer();
    for (var join in joins) {
      str.write(
          " left join ${join.foreignTableName} on ${join.tableName}.${join.mappedBy} = ${join.foreignTableName}.${join.foreignKey} ");
    }
    return str.toString();
  }

  Future<Paginated> paginated<T extends Model>({
    required String table,
    required int page,
    int perPage = 20,
    List<String> fields = const [],
    where = const {},
    String order = '',
    String group = '',
    String having = '',
    bool debug = false,
    List<JoinModel> joins = const [],
    required T Function(dynamic) instanceOfT,
  }) async {
    final c = await count(
        table: table, where: where, group: group, having: having, debug: debug);
    final list = await getAll(
      table: table,
      limit: [(page - 1) * perPage, perPage],
      fields: fields,
      where: where,
      order: order,
      group: group,
      having: having,
      debug: debug,
      joins: joins,
    );
    return Paginated(
      allPages: (c / perPage).ceil(),
      perPage: perPage,
      page: page,
      count: c,
      items: list.map(instanceOfT).toList(),
    );
  }

  ///```
  /// await db.getAll(
  ///   table: 'table',
  ///   fields: '*',
  ///   group: 'name',
  ///   having: 'name',
  ///   order: 'id desc',
  ///   limit: 10,//10 or '10 ,100'
  ///   debug: false,
  ///   where: {
  ///     'email': 'xxx@google.com',
  ///     'id': ['between', '1,4'],
  ///     'email2': ['=', 'sss@google.com'],
  ///     'news_title': ['like', '%name%'],
  ///     'user_id': ['>', 1],
  ///     '_SQL': '(`isNet`=1 OR `isNet`=2)',
  ///   },
  ///   //where:'`id`=1 AND name like "%jame%"',
  /// );
  ///```
  Future<List<dynamic>> getAll({
    required String table,
    List<String> fields = const [],
    where = const {},
    String order = '',
    dynamic limit = '',
    String group = '',
    String having = '',
    bool debug = false,
    List<JoinModel> joins = const [],
  }) async {
    if (group != '') group = 'GROUP BY $group';
    if (having != '') having = 'HAVING $having';
    if (order != '') order = 'ORDER BY $order';

    String _where = _whereParse(where);
    String rawTable = table;
    table = _tableParse(table);
    limit = _limitParse(limit);
    String join = _joinParse(joins);

    List<String> allFields = (fields +
        joins
            .map((e) => e.fields
                .map((f) => "${e.foreignTableName}.${f.name} as ${f.mappedAs}"))
            .flattened
            .toList());

    String _sql =
        'SELECT ${allFields.isEmpty ? "*" : allFields.join(",")} FROM $table $join $_where $group $having $order $limit';

    ResultFormat results =
        await query(_sql, debug: debug, joins: joins, forTable: rawTable);

    if (results.numOfRows > 0) {
      return results.rows;
    } else {
      return [];
    }
  }

  ///```
  /// await db.getOne(
  ///   table: 'table',
  ///   fields: '*',
  ///   group: 'name',
  ///   having: 'name',
  ///   order: 'id desc',
  ///   debug: false,
  ///   where: {
  ///     'email': 'xxx@google.com',
  ///     'id': ['between', '1,4'],
  ///     'email2': ['=', 'sss@google.com'],
  ///     'news_title': ['like', '%name%'],
  ///     'user_id': ['>', 1],
  ///     '_SQL': '(`isNet`=1 OR `isNet`=2)',
  ///   },
  ///   //where:'`id`=1 AND name like "%jame%"',
  /// );
  ///```
  Future<Map> getOne({
    required String table,
    List<String> fields = const [],
    where = const {},
    String group = '',
    String having = '',
    String order = '',
    bool debug = false,
    List<JoinModel> joins = const [],
  }) async {
    List<dynamic> res = await getAll(
      table: table,
      fields: fields,
      where: where,
      group: group,
      having: having,
      order: order,
      debug: debug,
      joins: joins,
    );

    if (res.isNotEmpty) {
      return res.first;
    } else {
      return {};
    }
  }

  ///table parse
  String _tableParse(String table) {
    String _prefix = _settings['prefix'];
    return _parseColumn(table, prefix: _prefix);
  }

  String _parseColumn(String text, {String prefix = ""}) {
    var _result = '';
    if (text.contains(',')) {
      var tbs = [];
      for (var tb in text.split(',')) {
        var vl = tb.split(' ');
        if (prefix == '') {
          tbs.add('`${vl.first}` ${vl.last}');
        } else {
          tbs.add('`$prefix${vl.first}` ${vl.last}');
        }
      }
      _result = tbs.join(',');
    } else {
      if (prefix == '') {
        _result = '`${text.trim()}`';
      } else {
        _result = '`$prefix${text.trim()}`';
      }
    }
    return _result;
  }

  ///..limit(10) or ..limit('10 ,100')
  String _limitParse(dynamic limit) {
    if (limit is int) {
      return 'LIMIT $limit';
    }
    if (limit is String && limit != '') {
      return 'LIMIT $limit';
    }
    if (limit is List && limit.length == 2) {
      return 'LIMIT ${limit[0]}, ${limit[1]}';
    }
    return '';
  }

  ///where parsw
  String _whereParse(dynamic where) {
    String _where = '';
    if (where is String && where != '') {
      _where = 'WHERE $where';
    } else if (where is Map && where.isNotEmpty) {
      var _keys = '';
      where.forEach((key, value) {
        if (key == '_SQL') {
          if (_keys == '') {
            _keys = value;
          } else {
            _keys += ' AND $value';
          }
        } else if (value is String || value is num) {
          if (value is String) {
            if (_keys == '') {
              _keys = '$key = \'${sqlEscapeString(value)}\'';
            } else {
              _keys += ' AND $key= \'${sqlEscapeString(value)}\'';
            }
          } else if (value is num) {
            if (_keys == '') {
              _keys = '($key = $value)';
            } else {
              _keys += ' AND ($key = $value)';
            }
          }
        } else if (value is List) {
          final joinOperation = (value.length == 3) ? value[2] : "AND";

          switch (value[0]) {
            case 'in':
            case 'notin':
            case 'between':
            case 'notbetween':
            case 'like':
            case 'notlike':
              Map _ex = {
                'in': 'IN',
                'notin': 'NOT IN',
                'between': 'BETWEEN',
                'notbetween': 'NOT BETWEEN',
                'like': 'LIKE',
                'notlike': 'NOT LIKE',
              };
              String _wh = '';
              if (value[0] == 'in' || value[0] == 'notin') {
                _wh = '$key ${_ex[value[0]]}(${value[1].join(',')})';
              }
              if (value[0] == 'between' || value[0] == 'notbetween') {
                _wh = '($key ${_ex[value[0]]} ${value[1]} AND ${value[2]})';
              }
              if (value[0] == 'like' || value[0] == 'notlike') {
                _wh =
                    '($key ${_ex[value[0]]} \'${sqlEscapeString(value[1])}\')';
              }

              if (_keys == '') {
                _keys = _wh;
              } else {
                _keys += ' $joinOperation $_wh';
              }
              break;
            case '>':
            case '<':
            case '=':
            case '<>':
            case '!=':
              //>,=,<,<>,!=
              var val = value[1];
              if (value[1] is String) {
                val = '\'${value[1]}\'';
              }
              String _wh = '($key ${value[0]} $val)';
              if (_keys == '') {
                _keys = _wh;
              } else {
                _keys += ' $joinOperation $_wh';
              }
              break;
          }
        }
      });
      _where = 'WHERE $_keys';
    }
    return _where;
  }

  ///errorRack
  Future<void> errorRollback() async {
    if (transTimes > 0) {
      rollback();
    }
  }

  ///close
  Future<void> close() async {
    if (!_settings['pool']) {
      (await singleConn).close();
    } else {
      (await poolConn).close();
    }
  }

  String _buildColumnInfo(ColumnInfo column) {
    return "${_parseColumn(column.name)} ${column.columnType.getSqlType(column.length)}  ${(column.nullable) ? "NULL" : "NOT NULL"}  ${(column.defaultValue == null ? (column.nullable) ? "default NULL" : "" : "default '${column.defaultValue}'")} ${column.isAutoIncrement ? "auto_increment" : ""} ";
  }

  String _buildKey(List<ColumnInfo> columns) {
    final key = columns.firstWhereOrNull((element) => element.isKey);
    if (key == null) return "";
    return ",PRIMARY KEY  (${_parseColumn(key.name)})";
  }

  String _buildUniq(String table, List<ColumnInfo> columns) {
    final uniq = columns.where((element) => element.unique);
    if (uniq.isEmpty) return "";
    return uniq
        .map((e) => ", constraint ${table}_${e.name} unique (${e.name})")
        .join(",\n");
  }

  Future<ResultFormat> createTableIfNotExist({
    required String table,
    required List<ColumnInfo> columns,
  }) async {
    final _table = _tableParse(table);
    final sql = '''
        CREATE TABLE IF NOT EXISTS $_table (
          ${columns.map((e) => _buildColumnInfo(e)).join(",\n")}
          ${_buildKey(columns)}
          ${_buildUniq(table, columns)}
        );
     ''';
    logger.i(sql);
    return await query(sql);
  }

  ///query
  Future<ResultFormat> query(String sql,
      {Map<String, dynamic> values = const {},
      debug = false,
      List<JoinModel> joins = const [],
      String forTable = ""}) async {
    var queryStr = '$sql  $values';
    if (debug) _sqlLog(queryStr);
    bool transaction = false;
    if (sql == 'start transaction' || sql == 'commit' || sql == 'rollback') {
      transaction = true;
    }
    try {
      IResultSet res;
      if (transaction) {
        if (_settings['pool']) {
          res = await (await poolConn).execute(sql, {});
        } else {
          res = await (await singleConn).execute(sql, {});
        }
      } else {
        if (_settings['pool']) {
          res = await (await poolConn).execute(sql, values);
        } else {
          res = await (await singleConn).execute(sql, values);
        }
      }

      ResultFormat _res = ResultFormat.from(res, joins, forTable);
      return _res;
    } catch (e) {
      _errorLog(e.toString());
      errorRollback();
      return ResultFormat.empty();
    }
  }

  ///query multi
  Future<List<int>> queryMulti(String sql, Iterable<List<Object?>> values,
      {debug = false, bool haveJoins = false, String forTable = ""}) async {
    var queryStr = '$sql  $values';
    if (debug) _sqlLog(queryStr);
    PreparedStmt stmt;
    if (_settings['pool']) {
      stmt = await (await poolConn).prepare(sql);
    } else {
      stmt = await (await singleConn).prepare(sql);
    }
    List<int> res = [];
    values.forEach(
      (val) async {
        res.add((await stmt.execute(val)).lastInsertID.toInt());
      },
    );
    await stmt.deallocate();
    return res;
  }

  ///error log report
  void _errorLog(String e) {
    if (errorLog != null) {
      errorLog!(e);
    } else {
      throw e;
    }
  }

  ///debug sql report
  void _sqlLog(String sql) {
    if (sqlLog != null) {
      sqlLog!(sql);
    }
  }

  ///SQL-escape a string.
  String sqlEscapeString(String sqlString) {
    if (!sqlEscape) {
      return sqlString;
    }
    if (sqlString == '') {
      return '';
    }
    //input = input.replaceAll('\\', '\\\\');
    sqlString = sqlString.replaceAll('\'', '\\\'');
    return sqlString;
  }
}

///Result Format
class ResultFormat {
  List cols = [];
  List rows = [];
  List rowsAssoc = [];
  int affectedRows = 0;
  int numOfRows = 0;
  int numOfColumns = 0;
  int lastInsertID = 0;
  Stream<ResultSetRow>? rowsStream;
  ResultFormat({
    required this.cols,
    required this.rows,
    required this.rowsAssoc,
    required this.affectedRows,
    required this.numOfRows,
    required this.numOfColumns,
    required this.lastInsertID,
    required this.rowsStream,
  });

  Map<dynamic, dynamic> addJoins(
    Map<dynamic, dynamic> row,
    Map<dynamic, dynamic> rawRow,
    List<JoinModel> joins,
    String forTable,
    Map<dynamic, dynamic> prevData,
  ) {
    Map<dynamic, dynamic> newRow = {...row};
    var primaryKey =
        row.keys.firstWhereOrNull((element) => element.startsWith(forTable));
    if (primaryKey == null) return {};
    var primaryValue = row[primaryKey];
    if (primaryValue == null) return {};
    var tableData =
        row.keys.where((element) => element.contains("$forTable\$"));
    if(tableData.isEmpty){
      tableData = rawRow.keys.where((element) => element.contains("$forTable\$"));
    }
    for (var keyForTable in tableData) {
      if (!prevData.containsKey(primaryValue)) prevData[primaryValue] = {};
      prevData[primaryValue]![keyForTable.substring(
          forTable.length + 1, keyForTable.length)] = row[keyForTable];
      newRow.removeWhere((key, value) => key == keyForTable);
    }
    joins.where((element) => element.tableName == forTable).forEach((join) {
      if (!prevData.containsKey(join.foreignTableName)) {
        prevData[primaryValue]![join.foreignTableName] = {};
      }
      prevData[primaryValue]![join.foreignTableName] = {
        ...prevData[primaryValue]![join.foreignTableName],
        ...addJoins(newRow, rawRow, joins, join.foreignTableName,
            prevData[primaryValue]![join.foreignTableName])
      };
    });
    return prevData;
  }

  Map<dynamic, dynamic> deepMerge(
      Map<dynamic, dynamic> map1, Map<dynamic, dynamic> map2) {
    final resultMap = Map.from(map1);

    map2.forEach((key, value) {
      if (map1[key] is Map && value is Map) {
        resultMap[key] = deepMerge(map1[key], value);
      } else {
        resultMap[key] = value;
      }
    });

    return resultMap;
  }

  Map<dynamic, Map<dynamic, dynamic>> buildResult(
      IResultSet results, List<JoinModel> joins, String forTable) {
    final listData = results.rows.map((e) => e.typedAssoc());
    List<Map<dynamic, Map<dynamic, dynamic>>> list = [];
    for (var row in listData) {
      // data = {...data};
      Map<dynamic, Map<dynamic, dynamic>> data = {};
      addJoins(Map.from(row), row, joins, forTable, data).forEach((key, value) {
        if (!data.containsKey(key)) {
          data[key] = {};
        }
        data[key] = {...data[key]!, ...value};
      });
      list.add(data);
    }
    Map<dynamic, Map<dynamic, dynamic>> joined = {};
    for (var map in list) {
      map.forEach((key, value) {
        if (joined[key] is Map) {
          value = deepMerge(joined[key]!, value);
        }
        joined[key] = value;
      });
    }
    return joined;
  }

  ResultFormat.from(
      IResultSet results, List<JoinModel> joins, String forTable) {
    List _rows = [];
    List _cols = [];
    List _rowsAssoc = [];
    if (results.rows.isNotEmpty) {
      _rows = buildResult(results, joins, forTable).values.toList();
    }
    if (results.cols.isNotEmpty) {
      for (var e in results.cols) {
        _cols.add({'name': e.name, 'type': e.type});
      }
    }
    cols = _cols;
    rows = _rows;
    rowsAssoc = _rowsAssoc;
    affectedRows = results.affectedRows.toInt();
    numOfRows = results.numOfRows;
    numOfColumns = results.numOfColumns;
    rowsStream = results.rowsStream;
    lastInsertID = results.lastInsertID.toInt();
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cols'] = cols;
    data['rows'] = rows;
    data['rowsAssoc'] = rowsAssoc;
    data['affectedRows'] = affectedRows;
    data['numOfRows'] = numOfRows;
    data['numOfColumns'] = numOfColumns;
    data['rowsStream'] = rowsStream;
    data['lastInsertID'] = lastInsertID;
    return data;
  }

  ResultFormat.empty() {
    cols = [];
    rows = [];
    affectedRows = 0;
    rowsAssoc = [];
    numOfRows = 0;
    numOfColumns = 0;
    rowsStream = null;
    lastInsertID = 0;
  }
}
