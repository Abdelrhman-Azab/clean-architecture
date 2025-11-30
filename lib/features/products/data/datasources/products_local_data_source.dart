import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';
import '../../../../core/error/failures.dart';

abstract class ProductsLocalDataSource {
  Future<List<ProductModel>> getLastProducts();
  Future<void> cacheProducts(List<ProductModel> products);
}

const String cachedProductsKey = 'CACHED_PRODUCTS';

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  final Box box;

  ProductsLocalDataSourceImpl({required this.box});

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final jsonString = json.encode(products.map((e) => e.toJson()).toList());
    await box.put(cachedProductsKey, jsonString);
  }

  @override
  Future<List<ProductModel>> getLastProducts() async {
    final jsonString = box.get(cachedProductsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return Future.value(jsonList.map((e) => ProductModel.fromJson(e)).toList());
    } else {
      throw const CacheFailure('No cached products found');
    }
  }
}
