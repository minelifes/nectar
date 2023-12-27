import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/nectar_orm_generator.dart';

Builder restGenerator(BuilderOptions options) =>
    SharedPartBuilder([NectarRestGenerator()], 'rest',
        allowSyntaxErrors: false);
