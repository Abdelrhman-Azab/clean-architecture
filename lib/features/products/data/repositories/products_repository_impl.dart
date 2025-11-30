import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_local_data_source.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;
  final ProductsLocalDataSource localDataSource;

  ProductsRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final productModels = await remoteDataSource.getProducts();
      localDataSource.cacheProducts(productModels);
      final products = productModels.map((model) => model.toEntity()).toList();
      return Right(products);
    } catch (e) {
      try {
        final localProductModels = await localDataSource.getLastProducts();
        final products = localProductModels.map((model) => model.toEntity()).toList();
        return Right(products);
      } on CacheFailure catch (cacheError) {
        return Left(CacheFailure(cacheError.message));
      } catch (localError) {
        return Left(CacheFailure(localError.toString()));
      }
    }
  }
}
