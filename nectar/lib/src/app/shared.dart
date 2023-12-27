import 'package:get_it/get_it.dart';

GetIt get getIt => GetIt.I;

T? inject<T extends Object>() => GetIt.I.get<T>();

registerSingleton<T extends Object>(T object) =>
    GetIt.I.registerSingleton(object);

registerFactory<T extends Object>(T Function() object) =>
    GetIt.I.registerFactory(object);
