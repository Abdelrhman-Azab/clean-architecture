import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class ProductsLocalDataSource {
  Future<List<ProductModel>> getLastProducts();
  Future<void> cacheProducts(List<ProductModel> products);
}

const String cachedProductsKey = 'CACHED_PRODUCTS';
const String cachedProductsMetaKey = 'CACHED_PRODUCTS_META';
const int cacheTTLSeconds = 3600;

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  final Box box;

  ProductsLocalDataSourceImpl({required this.box});

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final jsonString = json.encode(products.map((e) => e.toJson()).toList());
    await box.put(cachedProductsKey, jsonString);
    await box.put(cachedProductsMetaKey, DateTime.now().toIso8601String());
  }

  @override
  Future<List<ProductModel>> getLastProducts() async {
    final tsString = box.get(cachedProductsMetaKey) as String?;
    if (tsString == null) {
      throw CacheException('No cached products found');
    }
    final ts = DateTime.tryParse(tsString);
    if (ts == null) {
      throw CacheException('No cached products found');
    }
    final age = DateTime.now().difference(ts).inSeconds;
    if (age > cacheTTLSeconds) {
      throw CacheException('Cache expired');
    }
    final jsonString = box.get(cachedProductsKey) as String?;
    if (jsonString == null) {
      throw CacheException('No cached products found');
    }
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => ProductModel.fromJson(e)).toList();
  }
}
