import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductsRepository {
  Future<Either<Failure, List<Product>>> getProducts();
}
