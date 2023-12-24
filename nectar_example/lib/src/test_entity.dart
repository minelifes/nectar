import 'package:nectar/nectar.dart';

part 'test_entity.g.dart';

@Entity(tableName: "test")
abstract class _Test {
  @Id()
  String? id;

  @Column(name: "test_string")
  @SerializableField(name: "test_string")
  late String testString;
}
