import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/nectar_orm_generator.dart';

/// generate all model enhance files.
Builder ormGenerator(BuilderOptions options) =>
    SharedPartBuilder([NectarOrmGenerator()], 'orm', allowSyntaxErrors: false);
