import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../features/products/di/products_dependency.dart';
import 'dart:developer' as developer;

final sl = GetIt.instance;

Future<void> init() async {
  // External
  await Hive.initFlutter();
  final box = await Hive.openBox('products_cache');
  sl.registerLazySingleton(() => box);
  sl.registerLazySingleton(() {
    final dio = Dio(BaseOptions(headers: {'Accept': 'application/json', 'Content-Type': 'application/json'}));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['startTime'] = DateTime.now();
          developer.log('HTTP ${options.method} ${options.uri}', name: 'DIO');
          handler.next(options);
        },
        onResponse: (response, handler) {
          final start = response.requestOptions.extra['startTime'] as DateTime?;
          final dur = start != null ? DateTime.now().difference(start).inMilliseconds : null;
          developer.log(
            'HTTP ${response.statusCode} ${response.requestOptions.uri}${dur != null ? ' (${dur}ms)' : ''}',
            name: 'DIO',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          final status = error.response?.statusCode;
          developer.log(
            'HTTP ERROR${status != null ? ' $status' : ''} ${error.requestOptions.uri}: ${error.message}',
            name: 'DIO',
          );
          handler.next(error);
        },
      ),
    );
    return dio;
  });
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  // Features - Products
  await initProductsDependencies();
}
