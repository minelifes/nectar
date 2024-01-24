import 'dart:async';
import 'package:mysql_client/mysql_client.dart';
import 'package:collection/collection.dart';
import 'package:nectar/nectar.dart';

import 'column_info.dart';

///mysql helper
class MysqlUtils {
  ///pool connect
  late Future<MySQLConnectionPool> poolConn;

  ///single connect
  late Future<MySQLConnection> singleConn;

  ///mysql setting
  late Map _settings = {};

  ///query Times
  int queryTimes = 0;

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
    if (inserted.lastInsertID > 0) {
      return inserted.lastInsertID;
    }
    return insertData[primaryKeyName] ?? 1;
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
    table = _tableParse(table);

    ResultFormat results = await query(
        'SELECT count($fields) as _count FROM $table $_where $group $having',
        debug: debug);
    return results.rows.first['_count'];
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

    List<String> allFields =
        (fields + joins.map((e) => e.fields).flattened.toList());

    String _sql =
        'SELECT ${allFields.isEmpty ? "*" : allFields.join(",")} FROM $table $join $_where $group $having $order $limit';

    ResultFormat results = await query(_sql,
        debug: debug, haveJoins: joins.isNotEmpty, forTable: rawTable);

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
    int limit = 100,
    List<JoinModel> joins = const [],
  }) async {
    List<dynamic> res = await getAll(
      table: table,
      fields: fields,
      where: where,
      group: group,
      having: having,
      order: order,
      limit: limit,
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
            _keys = '${sqlEscapeString(value)}';
          } else {
            _keys += ' AND ${sqlEscapeString(value)}';
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
              print("we here $key");
              _keys = '($key = $value)';
            } else {
              _keys += ' AND ($key = $value)';
            }
          }
        } else if (value is List) {
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
                _keys += ' AND $_wh';
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
                _keys += ' AND $_wh';
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
        .map((e) => "constraint ${table}_${e.name} unique (${e.name})")
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
      bool haveJoins = false,
      String forTable = ""}) async {
    var queryStr = '$sql  $values';
    queryTimes++;
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

      ResultFormat _res = ResultFormat.from(res, haveJoins, forTable);
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
    queryTimes++;
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

  Map<String, dynamic> _mergeData(
    List<Map<String, dynamic>> data,
    String skipKey,
    List<String> prefixes,
  ) {
    Map<String, dynamic> mainMap = {};
    Map<String, List<Map<String, dynamic>>> groupedItems = {};

    for (var entry in data) {
      for (var prefix in prefixes) {
        groupedItems.putIfAbsent(prefix, () => []);
        Map<String, dynamic> tempMap = {};

        for (var key in entry.keys) {
          if (key.startsWith(skipKey)) continue;
          if (entry[key] != null && key.startsWith(prefix)) {
            tempMap[key] = entry[key];
          }
        }

        if (tempMap.isNotEmpty) {
          groupedItems[prefix]?.add(tempMap);
        }
      }
    }

    for (var prefix in prefixes) {
      mainMap[prefix] = groupedItems[prefix];
    }

    return mainMap;
  }

  Map<String, dynamic> _mergeAndGroupMaps(
      String tableName, bool haveJoins, List<Map<String, dynamic>> maps) {
    Map<String, dynamic> result = {};
    maps.first.forEach((key, value) {
      if (key.startsWith(tableName)) {
        result[key] = value;
      }
    });
    if (!haveJoins) return result;
    Set<String> tables = {};
    for (var e in maps) {
      for (var entry in e.keys) {
        if (entry.startsWith(tableName)) continue;
        final joinTable = entry.split("\$").first;
        tables.add(joinTable);
      }
    }

    return {...result, ..._mergeData(maps, tableName, tables.toList())};

    // for (var map in maps) {
    //   Map<String, dynamic> object = {};
    //   String joinTable = "";
    //   for (var entry in map.entries) {
    //     if (entry.key.startsWith(tableName)) continue;
    //     final joinTable = entry.key.split("_").first;
    //     if (!joins.containsKey(joinTable)) joins[joinTable] = [];
    //   }
    //   joins[joinTable] = object;
    // }

    return result;
  }

  ResultFormat.from(IResultSet results, bool haveJoins, String forTable) {
    List _rows = [];
    List _cols = [];
    List _rowsAssoc = [];
    if (results.rows.isNotEmpty) {
      Map<dynamic, List<Map<String, dynamic>>> dataWithSamePrimaryData = {};
      for (var e in results.rows) {
        final row = e.typedAssoc();
        var primaryKey = row.keys
            .firstWhereOrNull((element) => element.startsWith(forTable));
        if (primaryKey == null) continue;
        var primaryValue = row[primaryKey];
        if (!dataWithSamePrimaryData.containsKey(primaryValue)) {
          dataWithSamePrimaryData[primaryValue] = [];
        }
        dataWithSamePrimaryData[primaryValue]!.add(row);
      }

      // List<Map<String, dynamic>> result = dataWithSamePrimaryData.values
      //     .map((e) => _mergeAndGroupMaps(e))
      //     .toList();
      _rows = dataWithSamePrimaryData.values
          .map((value) => _mergeAndGroupMaps(forTable, haveJoins, value))
          .toList();

      // final Map<dynamic, Map<String, dynamic>> parsedData = {};
      // print("results.rows: ${results.rows.map((e) => e.typedAssoc())}");
      // for (var e in results.rows) {
      //   final Map<String, dynamic> object = {};
      //   final row = e.typedAssoc();
      //   var primaryKey = row.keys.firstWhere((element) => element.startsWith(forTable));
      //   var primaryValue = row[primaryKey];
      //   if (haveJoins) {
      //     if (!parsedData.containsKey(primaryKey)) {
      //       for (var element in row.keys) {
      //         if (element.startsWith(forTable)) {
      //           object[element] = row[element];
      //         } else {
      //           final foreignTable = element.split("_").first;
      //           if (!object.containsKey(foreignTable)) {
      //             object[foreignTable] = {};
      //           }
      //           object[foreignTable][element] = row[element];
      //         }
      //       }
      //       parsedData[row[primaryValue]] = object;
      //     } else {
      //       for (var element in row.keys) {
      //         if (!element.startsWith(forTable)){
      //           final foreignTable = element.split("_").first;
      //           if (!object.containsKey(foreignTable)) {
      //             object[foreignTable] = {};
      //           }
      //           object[foreignTable][element] = row[element];
      //         }
      //       }
      //       parsedData[row[primaryValue][foreignTable].add();
      //     }
      //
      //     // if (!parsedData.containsKey(primaryKey)) {
      //     //   parsedData[row[primaryKey]] = object;
      //     // }
      //     //
      //     // for (var element in row.keys) {
      //     //   if (element.startsWith(forTable)) {
      //     //     object[element] = row[element];
      //     //   } else {
      //     //     final foreignTable = element.split("_").first;
      //     //     if (!object.containsKey(foreignTable)) {
      //     //       object[foreignTable] = {};
      //     //     }
      //     //     object[foreignTable][element] = row[element];
      //     //   }
      //     // }
      //     // parsedData.add(object);
      //   } else {
      //     parsedData[primaryValue] = e.typedAssoc();
      //   }
      //   _rowsAssoc.add(e);
      // }
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
