import 'package:nectar/nectar.dart';

part 'role.g.dart';

@Entity(tableName: "Role")
class _Role {
  @Id()
  String? id;

  @Column()
  late String title;
}
