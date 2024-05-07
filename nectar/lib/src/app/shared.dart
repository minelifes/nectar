import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nectar/nectar.dart';
import 'package:uuid/uuid.dart';

GetIt get getIt => GetIt.I;

T? inject<T extends Object>() => GetIt.I.get<T>();

registerSingleton<T extends Object>(T object) =>
    GetIt.I.registerSingleton(object);

registerFactory<T extends Object>(T Function() object) =>
    GetIt.I.registerFactory(object);

String generateUUID() => Uuid().v4();

Logger get logger => Logger(
        printer: PrettyPrinter(
      methodCount: 0,
      printTime: true,
    ));

NectarContext get requestContext => use(Nectar.context);