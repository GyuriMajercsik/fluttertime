import 'package:equatable/equatable.dart';
import 'package:flutter_time/src/blocs/analytics_event.dart';
import 'package:flutter_time/src/model/product.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ProductsEvent extends Equatable {
  ProductsEvent([List props = const []]) : super(props);
}

class LoadProducts extends ProductsEvent implements AnalyticsEvent {
  final String user;

  LoadProducts(this.user);

  @override
  String toString() => 'LoadProducts';

  @override
  String get analyticsName => 'LoadProducts';

  @override
  Map<String, dynamic> get analyticsParameters => {};
}

class AddProduct extends ProductsEvent implements AnalyticsEvent {
  final Product product;

  AddProduct(this.product) : super([product]);

  @override
  String toString() => 'AddProduct { product: $product }';

  @override
  String get analyticsName => 'AddProduct';

  @override
  Map<String, dynamic> get analyticsParameters => {};
}

class UpdateProduct extends ProductsEvent implements AnalyticsEvent {
  final Product product;

  UpdateProduct(this.product) : super([product]);

  @override
  String toString() => 'UpdateProduct { product: $product }';

  @override
  String get analyticsName => 'UpdateProduct';

  @override
  Map<String, dynamic> get analyticsParameters => {};
}

class DeleteProduct extends ProductsEvent implements AnalyticsEvent {
  final Product product;

  DeleteProduct(this.product) : super([product]);

  @override
  String toString() => 'DeleteProduct { product: $product }';

  @override
  String get analyticsName => 'DeleteProduct';

  @override
  Map<String, dynamic> get analyticsParameters => {};
}
