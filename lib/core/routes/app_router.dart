import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/products/presentation/pages/products_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'products',
      builder: (context, state) => const ProductsPage(),
    ),
  ],
);
