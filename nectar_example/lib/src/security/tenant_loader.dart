import 'package:nectar/nectar.dart';

class AppTenantLoader extends TenantLoader {
  @override
  Future<DbSettings> dbForTenant(String tenant, DbSettings? masterCfg) async =>
      masterCfg!.copyWith(db: tenant);

  @override
  String get header => "ProjectID";

  @override
  Future<bool> isProjectValid(String tenant) async => true;
}
