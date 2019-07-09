import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_time/main.dart';
import 'package:flutter_time/src/blocs/authentication/bloc.dart';
import 'package:flutter_time/src/blocs/image_analyzer/image_analyzer_screen.dart';
import 'package:flutter_time/src/blocs/product/bloc.dart';
import 'package:flutter_time/src/blocs/product/live_product_editor.dart';
import 'package:flutter_time/src/blocs/product/live_product_list_item.dart';
import 'package:flutter_time/src/blocs/product/product_editor.dart';
import 'package:flutter_time/src/blocs/product/products_bloc.dart';
import 'package:flutter_time/src/blocs/speedometer/speedometer_screen.dart';
import 'package:flutter_time/src/firebase_notifications.dart';
import 'package:flutter_time/src/firebase_remote_config.dart';
import 'package:flutter_time/src/global_keys.dart';
import 'package:flutter_time/src/local_notifications.dart';
import 'package:flutter_time/src/model/remote_configuration.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';

class ProductsScreen extends StatefulWidget {
  final Logger _log = Logger('ProductsScreen');
  final String _owner;

  ProductsScreen({@required String owner})
      : assert(owner != null),
        _owner = owner,
        super(key: Key(owner));

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with WidgetsBindingObserver {
  Logger get _log => widget._log;

  ProductsBloc _productsBloc;
  LocalNotifications _localNotifications;
  FirebaseCloudMessaging _firebaseCloudMessaging;
  FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _firebaseRemoteConfigRepository = getIt<FirebaseRemoteConfigRepository>();
    _productsBloc = getIt<ProductsBloc>();
    _localNotifications = getIt<LocalNotifications>();
    _firebaseCloudMessaging = getIt<FirebaseCloudMessaging>();

    _firebaseCloudMessaging.subscribeForProductsChanges(widget._owner);
    _retrieveDynamicLink();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _log.info('Products screen resumed');
      _retrieveDynamicLink();
    }
  }

  Future<void> _retrieveDynamicLink() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.retrieveDynamicLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      _log.info('Deeplink is: ${deepLink.path}');

      // parsing path as /product/owner/id
      List<String> pathParts = deepLink.path.split('/');
      if (pathParts[1] == 'product') {
        var owner = pathParts[2];
        var productId = pathParts[3];
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return LiveProductEditor(
              owner: owner,
              productId: productId,
            );
          }),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    String weekendPromoEnabled =
        _firebaseRemoteConfigRepository.getString('weekend_promo_enabled');
    _log.info('Weekend promo enabled: $weekendPromoEnabled');

    var weekendPromoConfiguration =
        WeekendPromoConfiguration.fromJson(json.decode(weekendPromoEnabled));

    var title = weekendPromoConfiguration.enabled
        ? 'Products - ${weekendPromoConfiguration.discount}%'
        : 'Products';

    return Scaffold(
      key: productsGlobalKey,
      appBar: AppBar(
        title: Text(title),
        backgroundColor:
            weekendPromoConfiguration.enabled ? Colors.green : Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () => _openSpeedometer(context),
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.hatWizard),
            onPressed: () => _openImageAnalyzer(context),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              getIt<AuthenticationBloc>().dispatch(
                LoggedOut(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _buildNewProductWidget(context),
      body: BlocBuilder(
          bloc: _productsBloc,
          builder: (context, state) {
            if (state is ProductsLoading) {
              return Center(child: CircularProgressIndicator());
            }

            var productsScreen;
            if (state is ProductsNotLoaded) {
              productsScreen = Center(child: Text('Products not loaded'));
            }

            if (state is ProductsLoaded) {
              if (state.products.isEmpty) {
                productsScreen = Center(child: Text('No products found...'));
              } else {
                productsScreen = ListView.builder(
                    key: Key(widget._owner),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      return LiveProductItem(
                        productId: state.products[index].id,
                        owner: widget._owner,
                        weekendPromoConfiguration: weekendPromoConfiguration,
                      );
                    });
              }
            }

            return RefreshIndicator(
              onRefresh: _refreshProducts,
              child: productsScreen,
            );
          }),
    );
  }

  FloatingActionButton _buildNewProductWidget(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _openProductEditor(context),
      tooltip: 'Create product',
      child: Icon(Icons.add),
    );
  }

  void _openProductEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ProductEditor();
      }),
    );
  }

  void _openSpeedometer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return SpeedometerScreen();
      }),
    );
  }

  void _openImageAnalyzer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ImageAnalyzerScreen();
      }),
    );
  }

  Future<void> _refreshProducts() async {
    _productsBloc.dispatch(LoadProducts(widget._owner));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _localNotifications.dispose();
    _firebaseCloudMessaging.unsubscribeForProductsChange(widget._owner);
    super.dispose();
  }
}
