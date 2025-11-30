import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_products.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final GetProducts getProducts;

  ProductsCubit({required this.getProducts}) : super(const ProductsState.initial());

  Future<void> loadProducts() async {
    emit(const ProductsState.loading());
    final result = await getProducts(NoParams());
    result.fold(
      (failure) => emit(ProductsState.error(failure.message)),
      (products) => emit(ProductsState.loaded(products)),
    );
  }
}
