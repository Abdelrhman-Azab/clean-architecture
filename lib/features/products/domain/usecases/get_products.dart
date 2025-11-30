import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProducts implements UseCase<List<Product>, NoParams> {
  final ProductsRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) async {
    return await repository.getProducts();
  }
}
