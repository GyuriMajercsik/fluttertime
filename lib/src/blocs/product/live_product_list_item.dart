import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_time/main.dart';
import 'package:flutter_time/src/blocs/product/product_list_item.dart';
import 'package:flutter_time/src/model/product.dart';
import 'package:flutter_time/src/model/remote_configuration.dart';
import 'package:flutter_time/src/products_repository.dart';

class LiveProductItem extends StatefulWidget {
  final String productId;
  final String owner;
  final WeekendPromoConfiguration weekendPromoConfiguration;

  LiveProductItem(
      {@required this.productId,
      @required this.owner,
      this.weekendPromoConfiguration})
      : super(key: Key(productId));

  @override
  _LiveProductItemState createState() => _LiveProductItemState();
}

class _LiveProductItemState extends State<LiveProductItem> {
  Product _product;

  StreamSubscription<Product> subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var productsRepository = getIt<ProductsRepository>();
    subscription = productsRepository
        .subscribe(widget.owner, widget.productId)
        .listen((product) {
      if (product != null && product != _product) {
        if (mounted) {
          setState(() {
            _product = product;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return Center(child: CircularProgressIndicator());
    }

    return ProductItem(
      product: _product,
      weekendPromoConfiguration: widget.weekendPromoConfiguration,
    );
  }
}
