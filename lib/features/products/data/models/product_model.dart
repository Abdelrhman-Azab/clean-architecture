import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const ProductModel._(); // Added constructor for custom methods

  const factory ProductModel({
    required int id,
    @JsonKey(name: 'title') required String name,
    required String description,
    required double price,
    @JsonKey(name: 'image') required String imageUrl,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

  Product toEntity() {
    return Product(id: id.toString(), name: name, description: description, price: price, imageUrl: imageUrl);
  }
}
