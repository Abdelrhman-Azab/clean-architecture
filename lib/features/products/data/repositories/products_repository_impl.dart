import 'package:fpdart/fpdart.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_local_data_source.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;
  final ProductsLocalDataSource localDataSource;
  final InternetConnectionChecker connectionChecker;

  ProductsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    final isConnected = await connectionChecker.hasConnection;
    if (!isConnected) {
      try {
        final localProductModels = await localDataSource.getLastProducts();
        final products = localProductModels.map((model) => model.toEntity()).toList();
        return Right(products);
      } on CacheException {
        return Left(NetworkFailure('No internet connection'));
      }
    }

    try {
      final productModels = await remoteDataSource.getProducts();
      await localDataSource.cacheProducts(productModels);
      final products = productModels.map((model) => model.toEntity()).toList();
      return Right(products);
    } on ServerException catch (e) {
      try {
        final localProductModels = await localDataSource.getLastProducts();
        final products = localProductModels.map((model) => model.toEntity()).toList();
        return Right(products);
      } on CacheException {
        return Left(ServerFailure(e.message));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
