import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/products/di/products_dependency.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Dio());

  // Features - Products
  await initProductsDependencies();
}
