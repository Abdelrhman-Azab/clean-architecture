import '../../../../core/di/injection_container.dart';
import '../data/datasources/products_remote_data_source.dart';
import '../data/repositories/products_repository_impl.dart';
import '../domain/repositories/products_repository.dart';
import '../domain/usecases/get_products.dart';
import '../presentation/cubit/products_cubit.dart';

Future<void> initProductsDependencies() async {
  // Cubit
  sl.registerFactory(() => ProductsCubit(getProducts: sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetProducts(sl()));

  // Repository
  sl.registerLazySingleton<ProductsRepository>(() => ProductsRepositoryImpl(remoteDataSource: sl()));

  // Data Sources
  sl.registerLazySingleton<ProductsRemoteDataSource>(() => ProductsRemoteDataSourceImpl(dio: sl()));
}
