import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nectar/nectar.dart';
import 'package:nectar/src/callbacks/callbacks.dart';
import 'package:nectar/src/orm/mysql_utils.dart';

import 'db_settings.dart';

class Db {
  MysqlUtils? _utils;
  bool debug = false;
  var logger = Logger();

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

  void close() {
    _utils!.close();
  }

  void connect(
    DbSettings settings, {
    ValueCallback<String>? onError,
    ValueCallback<String>? sqlLog,
    ValueCallback<dynamic>? onConnected,
  }) {
    debug = settings.debug;
    _utils = MysqlUtils(
      settings: settings.toMap(),
      errorLog: onError ?? _onError,
      sqlLog: sqlLog ?? _onSql,
      connectInit: onConnected ?? _onConnect,
    );
    GetIt.I.registerSingleton<Db>(this);
  }

  Future<ResultFormat> query(
    String sql, {
    Map<String, dynamic> values = const {},
  }) =>
      _utils!.query(sql, values: values, debug: debug);

  Future<List<int>> queryMulti(String sql, Iterable<List<Object?>> values) =>
      _utils!.queryMulti(sql, values, debug: debug);

  Future<Map> getOne({
    required String table,
    List<String> fields = const [],
    where = const {},
    String group = '',
    String having = '',
    String order = '',
    List<JoinModel> joins = const [],
  }) =>
      _utils!.getOne(
        table: table,
        fields: fields,
        where: where,
        group: group,
        having: having,
        order: order,
        debug: debug,
        joins: joins,
      );

  Future<List<dynamic>> getAll({
    required String table,
    List<String> fields = const [],
    where = const {},
    String order = '',
    dynamic limit = '',
    String group = '',
    String having = '',
    List<JoinModel> joins = const [],
  }) =>
      _utils!.getAll(
        table: table,
        fields: fields,
        where: where,
        order: order,
        limit: limit,
        group: group,
        having: having,
        debug: debug,
        joins: joins,
      );

  Future<Map?> insert({
    required String table,
    required Map<String, dynamic> insertData,
    replace = false,
  }) =>
      _utils!.insertOrUpdate(
        table: table,
        insertData: insertData,
        replace: replace,
        debug: debug,
      );

  Future<int> insertAll({
    required String table,
    required List<Map<String, dynamic>> insertData,
    replace = false,
  }) =>
      _utils!.insertAll(
        table: table,
        insertData: insertData,
        replace: replace,
        debug: debug,
      );

  Future<ResultFormat> update({
    required String table,
    required Map<String, dynamic> updateData,
    required where,
  }) =>
      _utils!.update(
        table: table,
        updateData: updateData,
        where: where,
        debug: debug,
      );

  Future<int> delete({
    required String table,
    required where,
  }) =>
      _utils!.delete(
        table: table,
        where: where,
        debug: debug,
      );
}
