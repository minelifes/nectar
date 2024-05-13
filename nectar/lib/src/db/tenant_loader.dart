
import 'package:nectar/nectar.dart';

abstract class TenantLoader {

  ///Header which will used for detect tenant
  String get header;

  ///Method which allow to load custom db configuration for tenants
  ///Ex. load db user and passwd from master database and create new connection with this config
  ///or set same config with another dbName
  Future<DbSettings?> dbForTenant(String tenant, DbSettings? masterCfg);

  ///It allows to use custom mysql handler and connection for tenant
  MysqlUtils? customUtilsForTenant(String tenant) => null;
}