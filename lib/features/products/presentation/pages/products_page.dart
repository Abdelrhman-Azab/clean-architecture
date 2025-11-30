import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../widgets/product_item.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: BlocProvider(
        create: (context) => sl<ProductsCubit>()..loadProducts(),
        child: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (products) => ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductItem(product: products[index]);
                },
              ),
              error: (message) => Center(child: Text(message)),
            );
          },
        ),
      ),
    );
  }
}
