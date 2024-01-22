import 'package:nectar/nectar.dart';

part 'role.g.dart';

@Entity(tableName: "roles")
class _Role {
  @Id()
  String? key;

  @Column()
  late String name;
}
