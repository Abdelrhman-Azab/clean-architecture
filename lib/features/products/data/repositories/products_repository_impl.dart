import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final productModels = await remoteDataSource.getProducts();
      final products = productModels.map((model) => model.toEntity()).toList();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
