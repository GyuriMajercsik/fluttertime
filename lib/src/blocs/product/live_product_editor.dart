import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_time/main.dart';
import 'package:flutter_time/src/blocs/product/product_form.dart';
import 'package:flutter_time/src/model/product.dart';
import 'package:flutter_time/src/products_repository.dart';
import 'package:flutter_time/src/utils/share.dart';

class LiveProductEditor extends StatefulWidget {
  final String productId;
  final String owner;

  LiveProductEditor({@required this.productId, @required this.owner})
      : super(key: Key(productId));

  @override
  _LiveProductEditorState createState() => _LiveProductEditorState();
}

class _LiveProductEditorState extends State<LiveProductEditor> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Product editor'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _shareProduct(context);
            },
            icon: Icon(Icons.share),
          )
        ],
      ),
      body: ProductForm(
        product: _product,
      ),
    );
  }

  Future<Uri> _buildDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://fluttertime.page.link',
      link: Uri.parse(
          'https://example.com/product/${_product.owner}/${_product.id}'),
      androidParameters: AndroidParameters(
        packageName: 'com.fluttertime.skeleton',
        minimumVersion: 1,
      ),
//      iosParameters: IosParameters(
//        bundleId: 'com.example.ios',
//        minimumVersion: '1.0.1',
//        appStoreId: '123456789',
//      ),
//      googleAnalyticsParameters: GoogleAnalyticsParameters(
//        campaign: 'example-promo',
//        medium: 'social',
//        source: 'orkut',
//      ),
//      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
//        providerToken: '123456',
//        campaignToken: 'example-promo',
//      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Product',
        description: 'View product',
      ),
    );

    final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();
    return dynamicUrl.shortUrl;
  }

  void _shareProduct(BuildContext context) async {
    Uri uri = await _buildDynamicLink();

    shareProduct(context, uri.toString());
  }
}
