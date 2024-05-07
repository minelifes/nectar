import 'package:nectar/nectar.dart';

class AppTenantLoader extends TenantLoader {
  @override
  DbSettings dbForTenant(String tenant, DbSettings? masterCfg) =>
      masterCfg!.copyWith(db: tenant);

  @override
  String get header => "ProjectID";
}
