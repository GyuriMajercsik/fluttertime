import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_time/src/blocs/product/products_event.dart';
import 'package:flutter_time/src/blocs/product/products_state.dart';
import 'package:flutter_time/src/model/product.dart';
import 'package:flutter_time/src/products_repository.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final Logger log = Logger('ProductsBloc');
  final ProductsRepository productsRepository;

  ProductsBloc({@required this.productsRepository});

  @override
  ProductsState get initialState => ProductsLoading();

  @override
  Stream<ProductsState> mapEventToState(ProductsEvent event) async* {
    if (event is LoadProducts) {
      yield* _mapLoadProductsToState(event);
    } else if (event is AddProduct) {
      yield* _mapAddProductToState(event);
    } else if (event is UpdateProduct) {
      yield* _mapUpdateProductToState(event);
    } else if (event is DeleteProduct) {
      yield* _mapDeleteProductToState(event);
    }
  }

  Stream<ProductsState> _mapLoadProductsToState(LoadProducts event) async* {
    try {
      yield ProductsLoading();
      final products = await this.productsRepository.loadProducts(event.user);
      yield ProductsLoaded(products);
    } catch (error) {
      log.severe('Error occured while loading products: $error');
      yield ProductsNotLoaded();
    }
  }

  Stream<ProductsState> _mapAddProductToState(AddProduct event) async* {
    if (currentState is ProductsLoaded) {
      final List<Product> updatedProducts =
          List.from((currentState as ProductsLoaded).products)
            ..add(event.product);
      productsRepository.addNewProduct(event.product);
      yield ProductsLoaded(updatedProducts);
    }
  }

  Stream<ProductsState> _mapUpdateProductToState(UpdateProduct event) async* {
    if (currentState is ProductsLoaded) {
      final List<Product> updatedProducts =
          (currentState as ProductsLoaded).products.map((product) {
        return product.id == event.product.id ? event.product : product;
      }).toList();
      yield ProductsLoaded(updatedProducts);
      productsRepository.updateProduct(event.product);
    }
  }

  Stream<ProductsState> _mapDeleteProductToState(DeleteProduct event) async* {
    if (currentState is ProductsLoaded) {
      final updatedProducts = (currentState as ProductsLoaded)
          .products
          .where((product) => product.id != event.product.id)
          .toList();
      yield ProductsLoaded(updatedProducts);
      productsRepository.deleteProduct(event.product.id);
    }
  }
}
