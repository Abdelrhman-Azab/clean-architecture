import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(product.imageUrl),
        ),
        title: Text(product.name),
        subtitle: Text(product.description),
        trailing: Text('\$${product.price}'),
      ),
    );
  }
}
