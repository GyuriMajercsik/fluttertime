import 'package:equatable/equatable.dart';
import 'package:flutter_time/src/model/product.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ProductsState extends Equatable {
  ProductsState([List props = const []]) : super(props);
}

class ProductsLoading extends ProductsState {
  @override
  String toString() => 'ProductsLoading';
}

class ProductsLoaded extends ProductsState {
  final List<Product> products;

  ProductsLoaded([this.products = const []]) : super([products]);

  @override
  String toString() => 'ProductsLoaded { Products: $products }';
}

class ProductsNotLoaded extends ProductsState {
  @override
  String toString() => 'ProductsNotLoaded';
}
