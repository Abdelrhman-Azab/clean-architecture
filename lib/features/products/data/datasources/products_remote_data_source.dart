import 'package:dio/dio.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final Dio dio;

  ProductsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await dio.get('https://fakestoreapi.com/products');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
