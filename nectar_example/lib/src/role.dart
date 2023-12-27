import 'package:nectar/nectar.dart';

import 'test_entity.dart';

part 'role.g.dart';

@Entity(tableName: "Role")
class _Role {
  @Id()
  String? id;

  @Column()
  late String title;
}
