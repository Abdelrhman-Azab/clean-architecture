import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/products/di/products_dependency.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  await Hive.initFlutter();
  final box = await Hive.openBox('products_cache');
  sl.registerLazySingleton(() => box);
  sl.registerLazySingleton(() => Dio());

  // Features - Products
  await initProductsDependencies();
}
